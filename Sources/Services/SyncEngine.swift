import Foundation
import Observation
import SwiftData

enum ConnectivityState: Equatable {
    case offline
    case online
    case synchronizing

    var label: String {
        switch self {
        case .offline: "Offline"
        case .online: "Aggiornato"
        case .synchronizing: "Sincronizzazione…"
        }
    }
}

@MainActor
@Observable
final class SyncEngine {
    private(set) var state: ConnectivityState = .offline
    private(set) var lastSynchronization: Date?
    private(set) var lastError: String?

    func synchronize(using context: ModelContext, apiClient: APIClient) async {
        guard state != .synchronizing else { return }
        state = .synchronizing
        lastError = nil

        do {
            let remoteProperties = try await apiClient.fetchProperties()
            try merge(remoteProperties, into: context)
            try context.save()

            lastSynchronization = .now
            state = .online
        } catch {
            lastError = error.localizedDescription
            state = .offline
        }
    }

    private func merge(_ remoteProperties: [RemoteProperty], into context: ModelContext) throws {
        let descriptor = FetchDescriptor<PropertyRecord>()
        let localProperties = try context.fetch(descriptor)
        let localByID = Dictionary(uniqueKeysWithValues: localProperties.map { ($0.id, $0) })

        for remote in remoteProperties {
            let city = cityComponent(from: remote.indirizzo)

            if let local = localByID[remote.id] {
                local.title = remote.titolo
                local.address = remote.indirizzo
                local.city = city
                local.unitCount = remote.unitaCount
                local.updatedAt = .now
            } else {
                context.insert(
                    PropertyRecord(
                        id: remote.id,
                        title: remote.titolo,
                        address: remote.indirizzo,
                        city: city,
                        unitCount: remote.unitaCount
                    )
                )
            }
        }
    }

    private func cityComponent(from address: String) -> String {
        let parts = address
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        return parts.count > 1 ? parts.last ?? "" : ""
    }
}

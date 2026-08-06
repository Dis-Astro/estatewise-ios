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

    func synchronize(using context: ModelContext) async {
        guard state != .synchronizing else { return }
        state = .synchronizing

        // Prima milestone: il motore conserva la coda locale. Il trasporto API
        // verrà collegato dopo aver definito endpoint idempotenti nel backend.
        try? await Task.sleep(for: .milliseconds(550))

        lastSynchronization = .now
        state = .online
    }
}


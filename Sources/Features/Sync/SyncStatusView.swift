import SwiftData
import SwiftUI

struct SyncStatusView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SyncEngine.self) private var syncEngine
    @Query(sort: \SyncOperation.createdAt) private var operations: [SyncOperation]

    var body: some View {
        List {
            Section {
                LabeledContent("Stato") {
                    Label(syncEngine.state.label, systemImage: statusIcon)
                        .foregroundStyle(statusColor)
                }
                LabeledContent("Operazioni in coda", value: "\(operations.count)")
                if let date = syncEngine.lastSynchronization {
                    LabeledContent("Ultimo controllo") {
                        Text(date, format: .dateTime.day().month().hour().minute())
                    }
                }

                Button {
                    Task { await syncEngine.synchronize(using: modelContext) }
                } label: {
                    Label("Sincronizza ora", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(syncEngine.state == .synchronizing)
            }

            Section("Coda locale") {
                if operations.isEmpty {
                    Text("Nessuna modifica in attesa")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(operations) { operation in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(operation.operation.capitalized) \(operation.entityType)")
                                .font(.headline)
                            Text(operation.createdAt, format: .dateTime.day().month().hour().minute())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Sincronizzazione")
    }

    private var statusIcon: String {
        switch syncEngine.state {
        case .offline: "wifi.slash"
        case .online: "checkmark.icloud"
        case .synchronizing: "arrow.triangle.2.circlepath"
        }
    }

    private var statusColor: Color {
        switch syncEngine.state {
        case .offline: .orange
        case .online: .green
        case .synchronizing: .blue
        }
    }
}


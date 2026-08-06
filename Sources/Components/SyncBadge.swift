import SwiftUI

struct SyncBadge: View {
    let status: LocalSyncStatus

    var body: some View {
        Label(status.rawValue, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var icon: String {
        switch status {
        case .draft: "pencil"
        case .pending: "arrow.triangle.2.circlepath"
        case .synced: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private var color: Color {
        switch status {
        case .draft: .secondary
        case .pending: .orange
        case .synced: .green
        case .failed: .red
        }
    }
}


import SwiftData
import SwiftUI

struct SupervisorDashboardView: View {
    @Binding var selectedTab: AppTab
    @Environment(SyncEngine.self) private var syncEngine
    @Query private var reports: [ReportDraft]
    @Query private var properties: [PropertyRecord]

    private var pendingReports: Int {
        reports.filter { $0.syncStatus != .synced }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: 16)], spacing: 16) {
                    metricCard(title: "Immobili", value: properties.count, icon: "building.2.fill", color: .blue)
                    metricCard(title: "Verbali locali", value: reports.count, icon: "doc.text.fill", color: .indigo)
                    metricCard(title: "Da sincronizzare", value: pendingReports, icon: "arrow.triangle.2.circlepath", color: .orange)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Azioni rapide")
                        .font(.title2.bold())

                    Button {
                        selectedTab = .reports
                    } label: {
                        Label("Compila un verbale o sopralluogo", systemImage: "doc.badge.plus")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        selectedTab = .properties
                    } label: {
                        Label("Consulta gli immobili offline", systemImage: "building.2")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Buongiorno")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Label(syncEngine.state.label, systemImage: syncEngine.state == .offline ? "wifi.slash" : "checkmark.icloud")
                    .font(.caption)
                    .foregroundStyle(syncEngine.state == .offline ? .orange : .secondary)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Operatività supervisor")
                .font(.largeTitle.bold())
            Text("Dati disponibili sul dispositivo anche senza connessione.")
                .foregroundStyle(.secondary)
        }
    }

    private func metricCard(title: String, value: Int, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 46, height: 46)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading) {
                Text(value, format: .number)
                    .font(.title.bold())
                Text(title)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.quaternary)
        }
    }
}


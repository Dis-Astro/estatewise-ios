import SwiftData
import SwiftUI

struct ReportListView: View {
    @Query(sort: \ReportDraft.updatedAt, order: .reverse) private var reports: [ReportDraft]
    @State private var isPresentingEditor = false

    var body: some View {
        List(reports) { report in
            NavigationLink {
                ReportDetailView(report: report)
            } label: {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(report.type.rawValue)
                            .font(.headline)
                        Spacer()
                        SyncBadge(status: report.syncStatus)
                    }
                    Text(report.propertyTitle)
                    Text(report.reportDate, format: .dateTime.day().month().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Verbali")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Nuovo", systemImage: "plus") {
                    isPresentingEditor = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                ReportEditorView()
            }
        }
        .overlay {
            if reports.isEmpty {
                ContentUnavailableView(
                    "Nessun verbale",
                    systemImage: "doc.text",
                    description: Text("Crea un verbale anche senza connessione.")
                )
            }
        }
    }
}

private struct ReportDetailView: View {
    let report: ReportDraft

    var body: some View {
        Form {
            Section("Stato") {
                SyncBadge(status: report.syncStatus)
            }
            Section("Informazioni") {
                LabeledContent("Tipo", value: report.type.rawValue)
                LabeledContent("Immobile", value: report.propertyTitle)
                LabeledContent("Data") {
                    Text(report.reportDate, format: .dateTime.day().month().year())
                }
            }
            if !report.notes.isEmpty {
                Section("Note") {
                    Text(report.notes)
                }
            }
        }
        .navigationTitle(report.type.rawValue)
    }
}


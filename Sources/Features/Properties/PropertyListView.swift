import SwiftData
import SwiftUI

struct PropertyListView: View {
    @Query(sort: \PropertyRecord.title) private var properties: [PropertyRecord]

    var body: some View {
        List(properties) { property in
            NavigationLink {
                PropertyDetailView(property: property)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(property.title)
                        .font(.headline)
                    Text("\(property.address), \(property.city)")
                        .foregroundStyle(.secondary)
                    Label("\(property.unitCount) unità", systemImage: "door.left.hand.open")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Immobili")
        .overlay {
            if properties.isEmpty {
                ContentUnavailableView("Nessun immobile offline", systemImage: "building.2")
            }
        }
    }
}

private struct PropertyDetailView: View {
    let property: PropertyRecord

    var body: some View {
        Form {
            Section("Immobile") {
                LabeledContent("Nome", value: property.title)
                LabeledContent("Indirizzo", value: property.address)
                LabeledContent("Comune", value: property.city)
                LabeledContent("Unità", value: "\(property.unitCount)")
            }

            Section {
                NavigationLink("Nuovo verbale o sopralluogo") {
                    ReportEditorView(preselectedProperty: property)
                }
            }
        }
        .navigationTitle(property.title)
    }
}


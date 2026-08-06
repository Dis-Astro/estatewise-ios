import PhotosUI
import SwiftData
import SwiftUI

struct ReportEditorView: View {
    let preselectedProperty: PropertyRecord?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PropertyRecord.title) private var properties: [PropertyRecord]

    @State private var selectedPropertyID: String
    @State private var reportType: ReportType = .inspection
    @State private var reportDate = Date()
    @State private var notes = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(preselectedProperty: PropertyRecord? = nil) {
        self.preselectedProperty = preselectedProperty
        _selectedPropertyID = State(initialValue: preselectedProperty?.id ?? "")
    }

    var body: some View {
        Form {
            Section("Informazioni") {
                Picker("Immobile", selection: $selectedPropertyID) {
                    Text("Seleziona").tag("")
                    ForEach(properties) { property in
                        Text(property.title).tag(property.id)
                    }
                }
                .disabled(preselectedProperty != nil)

                Picker("Tipo", selection: $reportType) {
                    ForEach(ReportType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                DatePicker("Data", selection: $reportDate, displayedComponents: .date)
            }

            Section("Documentazione") {
                TextField("Note sullo stato dell'immobile", text: $notes, axis: .vertical)
                    .lineLimit(4...10)

                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    Label("Aggiungi fotografie", systemImage: "photo.badge.plus")
                }

                if !selectedPhotos.isEmpty {
                    Label("\(selectedPhotos.count) foto pronte per il salvataggio offline", systemImage: "checkmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Label(
                    "Il verbale viene salvato sul dispositivo e inserito nella coda di sincronizzazione.",
                    systemImage: "iphone.and.arrow.forward"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Nuovo verbale")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annulla") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") {
                    Task { await save() }
                }
                .disabled(selectedPropertyID.isEmpty || isSaving)
            }
        }
        .alert("Impossibile salvare", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Errore sconosciuto")
        }
    }

    @MainActor
    private func save() async {
        guard let property = properties.first(where: { $0.id == selectedPropertyID }) else { return }
        isSaving = true

        let report = ReportDraft(
            propertyID: property.id,
            propertyTitle: property.title,
            type: reportType,
            reportDate: reportDate,
            notes: notes,
            syncStatus: .pending
        )
        modelContext.insert(report)

        do {
            for photo in selectedPhotos {
                guard let data = try await photo.loadTransferable(type: Data.self) else { continue }
                let fileName = try await AttachmentStore.shared.save(data)
                modelContext.insert(AttachmentDraft(reportID: report.id, localFileName: fileName))
            }

            modelContext.insert(SyncOperation(
                entityID: report.id,
                entityType: "verbale",
                operation: "create"
            ))
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.delete(report)
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }
}


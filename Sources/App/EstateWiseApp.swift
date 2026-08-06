import SwiftData
import SwiftUI

@main
struct EstateWiseApp: App {
    private let modelContainer: ModelContainer
    @State private var syncEngine = SyncEngine()

    init() {
        do {
            modelContainer = try ModelContainer(
                for: PropertyRecord.self,
                ReportDraft.self,
                AttachmentDraft.self,
                SyncOperation.self
            )
        } catch {
            fatalError("Impossibile inizializzare l'archivio locale: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShellView()
                .environment(syncEngine)
                .task {
                    await DemoDataSeeder.seedIfNeeded(in: modelContainer.mainContext)
                    await syncEngine.synchronize(using: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}


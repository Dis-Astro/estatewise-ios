import SwiftData
import SwiftUI

@main
struct EstateWiseApp: App {
    private let modelContainer: ModelContainer
    @State private var session = AppSession()
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
            Group {
                if session.state == .signedIn {
                    AppShellView()
                        .task {
                            await syncEngine.synchronize(
                                using: modelContainer.mainContext,
                                apiClient: session.apiClient
                            )
                        }
                } else {
                    LoginView()
                }
            }
            .environment(session)
            .environment(syncEngine)
        }
        .modelContainer(modelContainer)
    }
}

import Foundation

actor AttachmentStore {
    static let shared = AttachmentStore()

    private let folderName = "ReportAttachments"

    func save(_ data: Data, preferredExtension: String = "jpg") throws -> String {
        let fileName = "\(UUID().uuidString).\(preferredExtension)"
        let folder = try attachmentFolder()
        try data.write(to: folder.appendingPathComponent(fileName), options: .atomic)
        return fileName
    }

    private func attachmentFolder() throws -> URL {
        let applicationSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = applicationSupport.appendingPathComponent(folderName, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }
}


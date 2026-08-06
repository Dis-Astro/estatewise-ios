import Foundation
import SwiftData

enum ReportType: String, CaseIterable, Identifiable {
    case delivery = "Consegna"
    case returnReport = "Riconsegna"
    case inspection = "Sopralluogo"

    var id: String { rawValue }
}

enum LocalSyncStatus: String {
    case draft = "Bozza"
    case pending = "Da sincronizzare"
    case synced = "Sincronizzato"
    case failed = "Errore"
}

@Model
final class PropertyRecord {
    @Attribute(.unique) var id: String
    var title: String
    var address: String
    var city: String
    var unitCount: Int
    var updatedAt: Date

    init(id: String = UUID().uuidString, title: String, address: String, city: String, unitCount: Int) {
        self.id = id
        self.title = title
        self.address = address
        self.city = city
        self.unitCount = unitCount
        updatedAt = .now
    }
}

@Model
final class ReportDraft {
    @Attribute(.unique) var id: String
    var propertyID: String
    var propertyTitle: String
    var typeRawValue: String
    var reportDate: Date
    var notes: String
    var syncStatusRawValue: String
    var createdAt: Date
    var updatedAt: Date

    var type: ReportType {
        get { ReportType(rawValue: typeRawValue) ?? .inspection }
        set { typeRawValue = newValue.rawValue }
    }

    var syncStatus: LocalSyncStatus {
        get { LocalSyncStatus(rawValue: syncStatusRawValue) ?? .draft }
        set { syncStatusRawValue = newValue.rawValue }
    }

    init(
        id: String = UUID().uuidString,
        propertyID: String,
        propertyTitle: String,
        type: ReportType,
        reportDate: Date,
        notes: String,
        syncStatus: LocalSyncStatus = .draft
    ) {
        self.id = id
        self.propertyID = propertyID
        self.propertyTitle = propertyTitle
        typeRawValue = type.rawValue
        self.reportDate = reportDate
        self.notes = notes
        syncStatusRawValue = syncStatus.rawValue
        createdAt = .now
        updatedAt = .now
    }
}

@Model
final class AttachmentDraft {
    @Attribute(.unique) var id: String
    var reportID: String
    var localFileName: String
    var createdAt: Date

    init(id: String = UUID().uuidString, reportID: String, localFileName: String) {
        self.id = id
        self.reportID = reportID
        self.localFileName = localFileName
        createdAt = .now
    }
}

@Model
final class SyncOperation {
    @Attribute(.unique) var id: String
    var entityID: String
    var entityType: String
    var operation: String
    var createdAt: Date
    var attemptCount: Int
    var lastError: String?

    init(
        id: String = UUID().uuidString,
        entityID: String,
        entityType: String,
        operation: String
    ) {
        self.id = id
        self.entityID = entityID
        self.entityType = entityType
        self.operation = operation
        createdAt = .now
        attemptCount = 0
    }
}


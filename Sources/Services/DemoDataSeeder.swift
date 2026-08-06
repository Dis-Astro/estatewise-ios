import SwiftData

@MainActor
enum DemoDataSeeder {
    static func seedIfNeeded(in context: ModelContext) async {
        let descriptor = FetchDescriptor<PropertyRecord>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        context.insert(PropertyRecord(
            title: "Palazzo Centro",
            address: "Via Roma 24",
            city: "Macerata",
            unitCount: 8
        ))
        context.insert(PropertyRecord(
            title: "Residenza Aurora",
            address: "Viale della Vittoria 18",
            city: "Civitanova Marche",
            unitCount: 5
        ))
        try? context.save()
    }
}


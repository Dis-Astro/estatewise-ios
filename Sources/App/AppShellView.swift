import SwiftUI

enum AppTab: Hashable, CaseIterable, Identifiable {
    case dashboard
    case properties
    case reports
    case sync

    var id: Self { self }

    var title: String {
        switch self {
        case .dashboard: "Oggi"
        case .properties: "Immobili"
        case .reports: "Verbali"
        case .sync: "Sincronizzazione"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "rectangle.grid.2x2"
        case .properties: "building.2"
        case .reports: "doc.text"
        case .sync: "arrow.triangle.2.circlepath"
        }
    }
}

struct AppShellView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                List {
                    ForEach(AppTab.allCases) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(selectedTab == tab ? Color.accentColor.opacity(0.12) : Color.clear)
                    }
                }
                .navigationTitle("EstateWise")
            } detail: {
                NavigationStack {
                    content(for: selectedTab)
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    NavigationStack {
                        content(for: tab)
                    }
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
                    .tag(tab)
                }
            }
        }
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .dashboard:
            SupervisorDashboardView(selectedTab: $selectedTab)
        case .properties:
            PropertyListView()
        case .reports:
            ReportListView()
        case .sync:
            SyncStatusView()
        }
    }
}

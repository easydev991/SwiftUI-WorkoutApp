import SWDesignSystem
import SwiftUI

struct RootScreen: View {
    @Binding var selectedTab: TabViewModel.Tab
    let unreadCount: Int
    let profileAlertsCount: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabViewModel.Tab.allCases, id: \.rawValue) { tab in
                tab.screen
                    .tabItem { tab.tabItemLabel }
                    .tag(tab)
                    .badge(makeBadgeCount(for: tab))
            }
        }
        .trackScreen(.root)
    }

    private func makeBadgeCount(for tab: TabViewModel.Tab) -> Int {
        switch tab {
        case .messages: unreadCount
        case .profile: profileAlertsCount
        default: 0
        }
    }
}

#if DEBUG
#Preview("Есть бейджи") {
    RootScreen(
        selectedTab: .constant(.map),
        unreadCount: 1,
        profileAlertsCount: 1
    )
    .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
    .environmentObject(ParksManager(isUITest: true, authHelper: MockAuthHelper()))
}

#Preview("Нет бейджей") {
    RootScreen(
        selectedTab: .constant(.map),
        unreadCount: 0,
        profileAlertsCount: 0
    )
    .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
    .environmentObject(ParksManager(isUITest: true, authHelper: MockAuthHelper()))
    .networkStatus(true)
}
#endif

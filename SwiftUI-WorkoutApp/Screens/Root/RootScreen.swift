import SWDesignSystem
import SwiftUI

struct RootScreen: View {
    @Binding var selectedTab: TabViewModel.Tab
    let unreadCount: Int
    let friendRequestsCount: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabViewModel.Tab.allCases, id: \.rawValue) { tab in
                tab.screen
                    .tabItem { tab.tabItemLabel }
                    .tag(tab)
                    .badge(makeBadgeCount(for: tab))
            }
        }
        .navigationViewStyle(.stack)
    }

    private func makeBadgeCount(for tab: TabViewModel.Tab) -> Int {
        switch tab {
        case .messages: unreadCount
        case .profile: friendRequestsCount
        default: 0
        }
    }
}

#if DEBUG
#Preview("Есть бейджи") {
    RootScreen(
        selectedTab: .constant(.map),
        unreadCount: 1,
        friendRequestsCount: 1
    )
    .environmentObject(ParksManager())
    .environmentObject(DefaultsService())
}

#Preview("Нет бейджей") {
    RootScreen(
        selectedTab: .constant(.map),
        unreadCount: 0,
        friendRequestsCount: 0
    )
    .environmentObject(ParksManager())
    .environmentObject(DefaultsService())
}
#endif

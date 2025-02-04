import SWDesignSystem
import SwiftUI

struct RootScreen: View {
    @Binding var selectedTab: TabViewModel.Tab
    let unreadCount: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabViewModel.Tab.allCases, id: \.rawValue) { tab in
                tab.screen
                    .tabItem { tab.tabItemLabel }
                    .tag(tab)
                    .badge(tab == .messages ? unreadCount : 0)
            }
        }
        .navigationViewStyle(.stack)
    }
}

#if DEBUG
#Preview("Есть бейдж для чатов") {
    RootScreen(
        selectedTab: .constant(.map),
        unreadCount: 1
    )
    .environmentObject(ParksManager())
    .environmentObject(DefaultsService())
}

#Preview("Нет бейджа") {
    RootScreen(
        selectedTab: .constant(.map),
        unreadCount: 0
    )
    .environmentObject(ParksManager())
    .environmentObject(DefaultsService())
}
#endif

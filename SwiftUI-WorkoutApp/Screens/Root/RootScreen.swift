import SWDesignSystem
import SwiftUI

struct RootScreen: View {
    @Environment(\.userFlags) private var userFlags
    @Binding var selectedTab: TabViewModel.Tab

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabViewModel.Tab.allCases, id: \.rawValue) { tab in
                tab.screen
                    .tabItem { tab.tabItemLabel }
                    .tag(tab)
            }
        }
        .navigationViewStyle(.stack)
    }
}

#if DEBUG
#Preview {
    RootScreen(selectedTab: .constant(.map))
        .environmentObject(ParksManager())
        .environmentObject(DefaultsService())
}
#endif

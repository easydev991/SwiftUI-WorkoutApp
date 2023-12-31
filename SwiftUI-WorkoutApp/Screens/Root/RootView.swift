import NetworkStatus
import SWDesignSystem
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: TabViewModel
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ForEach(TabViewModel.Tab.allCases, id: \.rawValue) { tab in
                tab.screen
                    .tabItem { tab.tabItemLabel }
                    .tag(tab)
            }
        }
        .navigationViewStyle(.stack)
        .animation(.spring(), value: defaults.isAuthorized)
    }
}

#if DEBUG
#Preview {
    RootView()
        .environmentObject(DefaultsService())
        .environmentObject(TabViewModel())
        .environmentObject(ParksManager())
        .environmentObject(NetworkStatus())
}
#endif

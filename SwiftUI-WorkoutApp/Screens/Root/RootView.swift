import DesignSystem
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(DefaultsService())
            .environmentObject(TabViewModel())
    }
}
#endif

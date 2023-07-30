import DesignSystem
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: TabViewModel
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        tabView
            .animation(.spring(), value: defaults.isAuthorized)
    }
}

private extension RootView {
    var tabView: some View {
        TabView(selection: $viewModel.selectedTab) {
            SportsGroundsMapView()
                .tabItem {
                    tabItemView(for: .map)
                }
                .tag(TabViewModel.Tab.map)
            EventsListView()
                .tabItem {
                    tabItemView(for: .events)
                }
                .tag(TabViewModel.Tab.events)
            DialogsScreen()
                .tabItem {
                    tabItemView(for: .messages)
                }
                .tag(TabViewModel.Tab.messages)
                .badge(defaults.unreadMessagesCount)
            JournalsScreen()
                .tabItem {
                    tabItemView(for: .journal)
                }
                .tag(TabViewModel.Tab.journal)
            ProfileScreen()
                .tabItem {
                    tabItemView(for: .profile)
                }
                .tag(TabViewModel.Tab.profile)
        }
        .navigationViewStyle(.stack)
    }

    func tabItemView(for tab: TabViewModel.Tab) -> some View {
        Group {
            Text(tab.title)
            switch tab {
            case .map:
                Image.sportsGroundIcon
            case .events:
                Image(systemName: Icons.Tabbar.events.rawValue)
            case .messages:
                Image(systemName: Icons.Tabbar.messages.rawValue)
            case .journal:
                Image(systemName: Icons.Tabbar.journals.rawValue)
            case .profile:
                Image(systemName: Icons.Tabbar.profile.rawValue)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(DefaultsService())
    }
}
#endif

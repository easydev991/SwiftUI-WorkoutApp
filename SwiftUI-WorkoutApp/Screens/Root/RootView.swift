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
                    Label("Площадки", systemImage: "map.circle")
                }
                .tag(TabViewModel.Tab.map)
            EventsListView()
                .tabItem {
                    Label("Мероприятия", systemImage: "person.3")
                }
                .tag(TabViewModel.Tab.events)
            DialogsScreen()
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(TabViewModel.Tab.messages)
                .badge(defaults.unreadMessagesCount)
            JournalsScreen()
                .tabItem {
                    Label("Дневники", systemImage: "list.bullet.circle")
                }
                .tag(TabViewModel.Tab.journal)
            ProfileScreen()
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(TabViewModel.Tab.profile)
        }
        .navigationViewStyle(.stack)
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

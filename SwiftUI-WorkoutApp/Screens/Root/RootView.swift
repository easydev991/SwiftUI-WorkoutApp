import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: TabViewModel
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        ZStack {
            if defaults.showWelcome {
                WelcomeView()
            } else {
                tabView
            }
        }
        .onChange(of: defaults.showWelcome, perform: swithToFirstTab)
        .animation(.spring(), value: defaults.showWelcome)
        .ignoresSafeArea()
    }
}

private extension RootView {
    var tabView: some View {
        TabView(selection: $viewModel.selectedTab) {
            SportsGroundsMapView()
                .tabItem {
                    Label("Площадки", systemImage: "map.circle")
                }
                .tag(Tab.map)
            EventsListView()
                .tabItem {
                    Label("Мероприятия", systemImage: "person.3")
                }
                .tag(Tab.events)
            DialogsScreen()
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(Tab.messages)
            JournalsScreen()
                .tabItem {
                    Label("Дневники", systemImage: "list.bullet.circle")
                }
                .tag(Tab.journal)
            ProfileScreen()
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .navigationViewStyle(.stack)
        .opacity(defaults.showWelcome ? 0 : 1)
    }

    func swithToFirstTab(_ newValue: Bool) {
        if !newValue { viewModel.selectTab(.map) }
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

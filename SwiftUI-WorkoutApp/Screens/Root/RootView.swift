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
        .animation(.easeInOut, value: defaults.showWelcome)
        .ignoresSafeArea()
    }
}

private extension RootView {
    var tabView: some View {
        TabView(selection: $viewModel.selectedTab) {
            EventsListView()
                .onAppear { viewModel.selectTab(.events) }
                .tabItem {
                    Label("Мероприятия", systemImage: "person.3")
                }
                .tag(Tab.events)
            DialogsScreen()
                .onAppear { viewModel.selectTab(.messages) }
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(Tab.messages)
            JournalsScreen()
                .onAppear { viewModel.selectTab(.journal) }
                .tabItem {
                    Label("Дневники", systemImage: "list.bullet.circle")
                }
                .tag(Tab.journal)
            SportsGroundsMapView()
                .onAppear { viewModel.selectTab(.map) }
                .tabItem {
                    Label("Площадки", systemImage: "map.circle")
                }
                .tag(Tab.map)
            ProfileScreen()
                .onAppear { viewModel.selectTab(.profile) }
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .transition(.move(edge: .trailing).combined(with: .scale))
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(DefaultsService())
    }
}

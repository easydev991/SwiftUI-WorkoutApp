//
//  ContentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }

    var body: some View {
        ZStack {
            if appState.showWelcome {
                WelcomeAuthView()
            } else {
                tabView()
            }
        }
        .animation(.default, value: appState.showWelcome)
        .ignoresSafeArea()
    }
}

extension ContentView {
    enum Tab: Int, Hashable {
        case events = 0, messages, journal, map, profile
    }
}

private extension ContentView {
    func tabView() -> some View {
        TabView(selection: $appState.selectedTab) {
            EventsView()
                .onAppear { appState.select(tab: .events) }
                .tabItem {
                    Label("Мероприятия", systemImage: "person.3")
                }
                .tag(Tab.events.rawValue)
            MessagesView()
                .onAppear { appState.select(tab: .messages) }
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(Tab.messages.rawValue)
            JournalsView()
                .onAppear { appState.select(tab: .journal) }
                .tabItem {
                    Label("Дневники", systemImage: "list.bullet.circle")
                }
                .tag(Tab.journal.rawValue)
            SportsGroundsView()
                .onAppear { appState.select(tab: .map) }
                .tabItem {
                    Label("Площадки", systemImage: "map.circle")
                }
                .tag(Tab.map.rawValue)
            ProfileView()
                .onAppear { appState.select(tab: .profile) }
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(Tab.profile.rawValue)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}

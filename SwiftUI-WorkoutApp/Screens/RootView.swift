//
//  RootView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var appState = RootViewModel()

    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }

    var body: some View {
        ZStack {
            if userDefaults.showWelcome {
                WelcomeAuthView()
            } else {
                tabView()
            }
        }
        .animation(.default, value: userDefaults.showWelcome)
        .ignoresSafeArea()
    }
}

extension RootView {
    enum Tab: Int, Hashable {
        case events = 0, messages, journal, map, profile
    }
}

private extension RootView {
    func tabView() -> some View {
        TabView(selection: $appState.selectedTab) {
            EventsView()
                .onAppear { appState.selectTab(.events) }
                .tabItem {
                    Label("Мероприятия", systemImage: "person.3")
                }
                .tag(Tab.events)
            MessagesView()
                .onAppear { appState.selectTab(.messages) }
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(Tab.messages)
            JournalsView()
                .onAppear { appState.selectTab(.journal) }
                .tabItem {
                    Label("Дневники", systemImage: "list.bullet.circle")
                }
                .tag(Tab.journal)
            SportsGroundsMapView()
                .onAppear { appState.selectTab(.map) }
                .tabItem {
                    Label("Площадки", systemImage: "map.circle")
                }
                .tag(Tab.map)
            ProfileView()
                .onAppear { appState.selectTab(.profile) }
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(UserDefaultsService())
    }
}

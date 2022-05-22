//
//  RootView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @State private var selectedTab = Tab.events

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
    enum Tab: Int, Hashable {
        case events = 0, messages, journal, map, profile
    }

    var tabView: some View {
        TabView(selection: $selectedTab) {
            EventsListView()
                .onAppear { selectTab(.events) }
                .tabItem {
                    Label("Мероприятия", systemImage: "person.3")
                }
                .tag(Tab.events)
            MessagesScreen()
                .onAppear { selectTab(.messages) }
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(Tab.messages)
            JournalsScreen()
                .onAppear { selectTab(.journal) }
                .tabItem {
                    Label("Дневники", systemImage: "list.bullet.circle")
                }
                .tag(Tab.journal)
            SportsGroundsMapView()
                .onAppear { selectTab(.map) }
                .tabItem {
                    Label("Площадки", systemImage: "map.circle")
                }
                .tag(Tab.map)
            ProfileScreen()
                .onAppear { selectTab(.profile) }
                .tabItem {
                    Label("Профиль", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .transition(.move(edge: .trailing).combined(with: .scale))
        .navigationViewStyle(.stack)
    }

    func selectTab(_ tab: RootView.Tab) {
        selectedTab = tab
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(DefaultsService())
    }
}

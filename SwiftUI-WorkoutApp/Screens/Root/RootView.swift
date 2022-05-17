//
//  RootView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = RootViewModel()

    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }

    var body: some View {
        ZStack {
            if defaults.showWelcome {
                WelcomeAuthView()
            } else {
                tabView
            }
        }
        .animation(.easeInOut, value: defaults.showWelcome)
        .ignoresSafeArea()
    }
}

extension RootView {
    enum Tab: Int, Hashable {
        case events = 0, messages, journal, map, profile
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
            MessagesView()
                .onAppear { viewModel.selectTab(.messages) }
                .tabItem {
                    Label("Сообщения", systemImage: "message.fill")
                }
                .tag(Tab.messages)
            JournalsView()
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
            ProfileView()
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
            .environmentObject(UserDefaultsService())
    }
}

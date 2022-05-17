//
//  SwiftUI_WorkoutAppApp.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var defaults = UserDefaultsService()
    @StateObject private var sportsGrounds = SportsGroundsService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(defaults)
                .environmentObject(sportsGrounds)
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .background:
#if DEBUG
                print("---background")
#endif
            case .inactive:
#if DEBUG
                print("---inactive")
#endif
            case .active:
#if DEBUG
                print("---active")
#endif
            @unknown default:
#if DEBUG
                print("---unknown")
#endif
            }
        }
    }
}

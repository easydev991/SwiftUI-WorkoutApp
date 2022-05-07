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

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(defaults)
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .background:
                print("---background")
            case .inactive:
                print("---inactive")
            case .active:
                print("---active")
            @unknown default:
                print("---unknown")
            }
        }
    }
}

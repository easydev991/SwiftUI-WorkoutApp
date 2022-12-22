import SwiftUI

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = CheckNetworkService()

    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(tabViewModel)
                .environmentObject(network)
                .environmentObject(defaults)
        }
        .onChange(of: scenePhase) {
            if case .background = $0 {
                defaults.setUserNeedUpdate(true)
            }
#if DEBUG
            print("--- scenePhase = \($0)")
#endif
        }
    }
}

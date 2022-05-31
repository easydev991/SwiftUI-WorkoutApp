import SwiftUI

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = CheckNetworkService()

    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(tabViewModel)
                .environmentObject(network)
                .environmentObject(defaults)
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

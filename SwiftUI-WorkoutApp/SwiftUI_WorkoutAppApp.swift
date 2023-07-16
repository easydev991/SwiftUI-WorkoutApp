import DesignSystem
import NetworkStatus
import SwiftUI

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = NetworkStatus()

    init() {
        setupAppearance()
        prepareForUITestIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(tabViewModel)
                .environmentObject(network)
                .environmentObject(defaults)
                .accentColor(.swAccent)
                .onAppear {
                    AppThemeService.set(defaults.appTheme)
                }
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

private extension SwiftUI_WorkoutAppApp {
    func setupAppearance() {
        UITextField.appearance().clearButtonMode = .whileEditing
        let tabBarAppearance = UITabBarAppearance()
        let navBarAppearance = UINavigationBarAppearance()
        [tabBarAppearance, navBarAppearance].forEach {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = .init(Color.swBackground)
            $0.shadowColor = nil
        }
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        #warning("Убрать при переходе на iOS 16")
        UITextView.appearance().backgroundColor = .clear
    }

    func prepareForUITestIfNeeded() {
        if ProcessInfo.processInfo.arguments.contains("UITest") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UIView.setAnimationsEnabled(false)
        }
    }
}

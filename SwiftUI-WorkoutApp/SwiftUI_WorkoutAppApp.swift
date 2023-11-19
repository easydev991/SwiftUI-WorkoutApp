import FileManager991
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWNetworkClient
import Utils

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = NetworkStatus()
    @StateObject private var groundsManager = SportsGroundsManager()
    @State private var countriesUpdateTask: Task<Void, Never>?
    @State private var socialUpdateTask: Task<Void, Never>?
    private let countriesStorage = SWAddress()

    init() {
        setupAppearance()
        prepareForUITestIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, .init(identifier: defaults.appLanguage.code))
                .environmentObject(tabViewModel)
                .environmentObject(network)
                .environmentObject(defaults)
                .environmentObject(groundsManager)
                .onAppear {
                    AppThemeService.set(defaults.appTheme)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                updateCountriesIfNeeded()
                socialUpdateTask = Task {
                    let isUpdated = await SWClient(with: defaults)
                        .getSocialUpdates(userID: defaults.mainUserInfo?.id)
                    defaults.setUserNeedUpdate(!isUpdated)
                }
            default:
                [socialUpdateTask, countriesUpdateTask].forEach { $0?.cancel() }
                defaults.setUserNeedUpdate(true)
            }
        }
    }

    private func updateCountriesIfNeeded() {
        guard countriesStorage.needUpdate(defaults.lastCountriesUpdateDate) else { return }
        countriesUpdateTask = Task {
            if let countries = try? await SWClient(with: defaults).getCountries(),
               countriesStorage.save(countries) {
                defaults.didUpdateCountries()
            }
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

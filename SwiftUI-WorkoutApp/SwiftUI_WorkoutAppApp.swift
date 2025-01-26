import FileManager991
import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import Utils

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = NetworkStatus()
    @StateObject private var parksManager = ParksManager()
    @State private var countriesUpdateTask: Task<Void, Never>?
    @State private var socialUpdateTask: Task<Void, Never>?
    private let countriesStorage = SWAddress()
    private var client: SWClient { SWClient(with: defaults) }
    private var colorScheme: ColorScheme? {
        switch defaults.appTheme {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }

    init() {
        setupAppearance()
        prepareForUITestIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootScreen(selectedTab: $tabViewModel.selectedTab)
                .environmentObject(tabViewModel)
                .environmentObject(network)
                .environmentObject(defaults)
                .environmentObject(parksManager)
                .preferredColorScheme(colorScheme)
                .environment(\.isNetworkConnected, network.isConnected)
                .environment(\.userFlags, defaults.userFlags)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                updateCountriesIfNeeded()
                guard let mainUserId = defaults.mainUserInfo?.id else { return }
                socialUpdateTask = Task {
                    if let result = await client.getSocialUpdates(userID: mainUserId) {
                        try? defaults.saveFriendsIds(result.friends.map(\.id))
                        try? defaults.saveFriendRequests(result.friendRequests)
                        try? defaults.saveBlacklist(result.blacklist)
                        defaults.setUserNeedUpdate(false)
                    }
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
            if let countries = try? await client.getCountries(),
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
        if !DeviceOSVersionChecker.iOS16Available {
            UITextView.appearance().backgroundColor = .clear
        }
    }

    func prepareForUITestIfNeeded() {
        if ProcessInfo.processInfo.arguments.contains("UITest") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UIView.setAnimationsEnabled(false)
        }
    }
}

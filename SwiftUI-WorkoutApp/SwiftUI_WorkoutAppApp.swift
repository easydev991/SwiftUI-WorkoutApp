import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

@main
struct SwiftUI_WorkoutAppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = NetworkStatus()
    @StateObject private var parksManager = ParksManager()
    @StateObject private var dialogsViewModel = DialogsViewModel()
    @State private var countriesUpdateTask: Task<Void, Never>?
    @State private var socialUpdateTask: Task<Void, Never>?
    @State private var dialogsUpdateTask: Task<Void, Never>?
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
            RootScreen(
                selectedTab: $tabViewModel.selectedTab,
                unreadCount: defaults.unreadMessagesCount
            )
            .environmentObject(tabViewModel)
            .environmentObject(network)
            .environmentObject(defaults)
            .environmentObject(parksManager)
            .environmentObject(dialogsViewModel)
            .preferredColorScheme(colorScheme)
            .environment(\.isNetworkConnected, network.isConnected)
            .environment(\.userFlags, defaults.userFlags)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                updateCountriesIfNeeded()
                updateSocialInfoIfNeeded()
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

    private func updateSocialInfoIfNeeded() {
        guard let mainUserId = defaults.mainUserInfo?.id else { return }
        socialUpdateTask = Task {
            if let result = await client.getSocialUpdates(userID: mainUserId) {
                try? defaults.saveFriendsIds(result.friends.map(\.id))
                try? defaults.saveFriendRequests(result.friendRequests)
                try? defaults.saveBlacklist(result.blacklist)
                defaults.setUserNeedUpdate(false)
            }
        }
        dialogsUpdateTask = Task {
            try? await dialogsViewModel.askForDialogs(refresh: true, defaults: defaults)
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
        let tabBarItemAppearance = makeTabBarItemAppearance()
        tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = tabBarItemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        fixAlertAccentColor()
        if !DeviceOSVersionChecker.iOS16Available {
            UITextView.appearance().backgroundColor = .clear
        }
    }

    /// Исправляет баг с accentColor у алертов,  [обсуждение](https://developer.apple.com/forums/thread/673147)
    ///
    /// Без этой настройки у всех алертов при первом появлении стандартный tintColor (синий),
    /// а при нажатии он меняется на AccentColor в проекте
    func fixAlertAccentColor() {
        UIView.appearance().tintColor = .accent
    }

    /// Настройки цветовых параметров для табов в таббаре
    func makeTabBarItemAppearance() -> UITabBarItemAppearance {
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.iconColor = .init(.swSmallElements)
        tabBarItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(.swSmallElements)]
        tabBarItemAppearance.normal.badgeBackgroundColor = .accent
        tabBarItemAppearance.normal.badgeTextAttributes = [.foregroundColor: UIColor(.swBackground)]
        return tabBarItemAppearance
    }

    #if DEBUG
    func prepareForUITestIfNeeded() {
        if ProcessInfo.processInfo.arguments.contains("UITest") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UIView.setAnimationsEnabled(false)
        }
    }
    #endif
}

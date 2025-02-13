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
                unreadCount: defaults.unreadMessagesCount,
                friendRequestsCount: defaults.friendRequestsList.count
            )
            .environmentObject(tabViewModel)
            .environmentObject(defaults)
            .environmentObject(parksManager)
            .environmentObject(dialogsViewModel)
            .preferredColorScheme(colorScheme)
            .environment(\.isNetworkConnected, network.isConnected)
            .environment(\.userFlags, defaults.userFlags)
            .task(id: defaults.isAuthorized) {
                try? await dialogsViewModel.getDialogs(defaults: defaults)
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                updateCountriesIfNeeded()
            default:
                updateAppIconBadge()
                defaults.setUserNeedUpdate(true)
            }
        }
    }

    private func updateCountriesIfNeeded() {
        guard countriesStorage.needUpdate(defaults.lastCountriesUpdateDate),
              countriesUpdateTask == nil
        else { return }
        countriesUpdateTask = Task {
            if let countries = try? await client.getCountries(),
               countriesStorage.save(countries) {
                defaults.didUpdateCountries()
            }
        }
    }

    @available(iOS, deprecated: 16, message: "Заменить на async-вариант")
    private func updateAppIconBadge() {
        func setupAppIconBadge() {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = defaults.appIconBadgeCount
            }
        }
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.badge]) { granted, _ in
                    guard granted else { return }
                    setupAppIconBadge()
                }
            case .authorized, .provisional:
                setupAppIconBadge()
            default: break
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
        return tabBarItemAppearance
    }

    func prepareForUITestIfNeeded() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("UITest") {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UIView.setAnimationsEnabled(false)
        }
        #endif
    }
}

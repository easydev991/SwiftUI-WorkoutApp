import OSLog
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

@main
struct SwiftUI_WorkoutAppApp: App {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "SwiftUI_WorkoutAppApp"
    )
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults = DefaultsService()
    @StateObject private var network = NetworkStatus()
    @StateObject private var parksManager = ParksManager()
    @StateObject private var dialogsViewModel = DialogsListScreen.ViewModel()
    @StateObject private var profileViewModel = MainUserProfileScreen.ViewModel()
    /// Используется для обновления диалогов
    @State private var lastScenePhase: ScenePhase?
    @State private var dialogsUpdateTask: Task<Void, Never>?
    @State private var profileUpdateTask: Task<Void, Never>?
    @State private var countriesUpdateTask: Task<Void, Never>?
    @State private var badgeUpdateTask: Task<Void, Never>?
    private let countriesStorage = SWAddress()
    /// Нужно ли обновить диалоги/профиль при смене фазы приложения
    private var shouldUpdateDialogsAndProfile: Bool {
        lastScenePhase == .inactive || lastScenePhase == .background
    }

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
            .environmentObject(profileViewModel)
            .preferredColorScheme(colorScheme)
            .environment(\.isNetworkConnected, network.isConnected)
            .environment(\.userFlags, defaults.userFlags)
            .task(id: defaults.isAuthorized) {
                await dialogsViewModel.getDialogs(defaults: defaults)
            }
        }
        .onChange(of: defaults.isAuthorized, perform: updateAppIconBadgeIfNeeded)
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                updateCountriesIfNeeded()
                updateDialogsIfNeeded()
                updateProfileIfNeeded()
            case .background:
                updateAppIconBadgeIfNeeded(defaults.isAuthorized)
                defaults.setUserNeedUpdate(true)
            default: break
            }
            lastScenePhase = phase
        }
    }

    private func updateCountriesIfNeeded() {
        guard countriesStorage.needUpdate(defaults.lastCountriesUpdateDate),
              countriesUpdateTask == nil
        else { return }
        countriesUpdateTask = Task {
            do {
                let countries = try await client.getCountries()
                try countriesStorage.save(countries)
                defaults.didUpdateCountries()
            } catch {
                logger.error("Не смогли сохранить список стран, ошибка: \(error.localizedDescription)")
            }
        }
    }

    private func updateDialogsIfNeeded() {
        guard shouldUpdateDialogsAndProfile else {
            return
        }
        dialogsUpdateTask?.cancel()
        dialogsUpdateTask = Task {
            await dialogsViewModel.getDialogs(refresh: true, defaults: defaults)
        }
    }

    private func updateProfileIfNeeded() {
        guard shouldUpdateDialogsAndProfile else {
            return
        }
        profileUpdateTask?.cancel()
        profileUpdateTask = Task {
            try? await profileViewModel.getUserProfile(refresh: true, defaults: defaults)
        }
    }

    private func updateAppIconBadgeIfNeeded(_ isAuthorized: Bool) {
        guard isAuthorized else {
            UIApplication.shared.applicationIconBadgeNumber = 0
            return
        }
        badgeUpdateTask?.cancel()
        badgeUpdateTask = Task {
            let center = UNUserNotificationCenter.current()
            let granted = try? await center.requestAuthorization(options: [.badge])
            guard granted == true else { return }
            guard UIApplication.shared.applicationIconBadgeNumber != defaults.appIconBadgeCount else { return }
            UIApplication.shared.applicationIconBadgeNumber = defaults.appIconBadgeCount
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

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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var tabViewModel = TabViewModel()
    @StateObject private var defaults: DefaultsService
    @StateObject private var network = NetworkStatus()
    @StateObject private var parksManager: ParksManager
    @StateObject private var dialogsViewModel: DialogsListScreen.ViewModel
    @StateObject private var profileViewModel: MainUserProfileScreen.ViewModel
    @StateObject private var reviewService = ReviewService()
    /// Используется для обновления диалогов
    @State private var lastScenePhase: ScenePhase?
    @State private var dialogsUpdateTask: Task<Void, Never>?
    @State private var profileUpdateTask: Task<Void, Never>?
    @State private var countriesUpdateTask: Task<Void, Never>?
    @State private var badgeUpdateTask: Task<Void, Never>?
    private let countriesStorage = SWAddress()
    private let analyticsService: AnalyticsService
    /// Нужно ли обновить диалоги/профиль при смене фазы приложения
    private var shouldUpdateDialogsAndProfile: Bool {
        lastScenePhase == .inactive || lastScenePhase == .background
    }

    init() {
        let isUITest = Constants.isUITest
        let analyticsService: AnalyticsService
        let authHelper: AuthHelperImp
        #if DEBUG
        authHelper = isUITest ? MockAuthHelper() : AuthHelperImp()
        analyticsService = isUITest
            ? AnalyticsService()
            : AnalyticsService(provider: FirebaseAnalyticsProvider())
        if isUITest {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UIView.setAnimationsEnabled(false)
        }
        #else
        authHelper = AuthHelperImp()
        analyticsService = AnalyticsService(provider: FirebaseAnalyticsProvider())
        #endif
        _defaults = .init(wrappedValue: .init(authHelper: authHelper))
        _parksManager = .init(
            wrappedValue: .init(
                isUITest: isUITest,
                authHelper: authHelper
            )
        )
        _dialogsViewModel = .init(
            wrappedValue: .init(
                isUITest: isUITest,
                authHelper: authHelper,
                analytics: analyticsService
            )
        )
        _profileViewModel = .init(
            wrappedValue: .init(
                isUITest: isUITest,
                analytics: analyticsService
            )
        )
        self.analyticsService = analyticsService
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootScreen(
                selectedTab: $tabViewModel.selectedTab,
                unreadCount: defaults.unreadMessagesCount,
                profileAlertsCount: defaults.getProfileBadgeCount(
                    isMissingAddress: parksManager.showMissingAddressBadge
                )
            )
            .environment(\.horizontalSizeClass, .compact)
            .environmentObject(tabViewModel)
            .environmentObject(defaults)
            .environmentObject(parksManager)
            .environmentObject(dialogsViewModel)
            .environmentObject(profileViewModel)
            .environmentObject(reviewService)
            .networkStatus(network.isOnline)
            .preferredColorScheme(defaults.appTheme.colorScheme)
            .environment(\.userFlags, defaults.userFlags)
            .environment(\.analyticsService, analyticsService)
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
        guard countriesUpdateTask == nil else { return }
        countriesUpdateTask = Task {
            defer { countriesUpdateTask = nil }
            do {
                #if DEBUG
                let client: CountriesClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: CountriesClient = SWClient(with: defaults.authHelper)
                #endif
                let didUpdate = try await countriesStorage.updateIfNeeded(
                    lastUpdateDate: defaults.lastCountriesUpdateDate,
                    client: client
                )
                if didUpdate {
                    defaults.didUpdateCountries()
                    logger.info("Справочник стран успешно обновлен")
                }
            } catch {
                analyticsService.log(.appError(kind: .countriesUpdateFailed, error: error))
                logger.error("Не смогли обновить список стран, ошибка: \(error.localizedDescription)")
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
            do {
                try await profileViewModel.getUserProfile(refresh: true, defaults: defaults)
            } catch {
                logger.error("Ошибка обновления профиля при разворачивании: \(error.localizedDescription)")
            }
        }
    }

    private func updateAppIconBadgeIfNeeded(_ isAuthorized: Bool) {
        let center = UNUserNotificationCenter.current()
        guard isAuthorized else {
            center.setBadgeCount(0)
            return
        }
        badgeUpdateTask?.cancel()
        badgeUpdateTask = Task {
            let granted = try? await center.requestAuthorization(options: [.badge])
            guard granted == true else { return }
            let appIconBadgeCount = defaults.appIconBadgeCount
            guard UIApplication.shared.applicationIconBadgeNumber != appIconBadgeCount else { return }
            try? await center.setBadgeCount(appIconBadgeCount)
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
}

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
    @State private var countriesUpdateTask: Task<Void, Never>?
    @State private var socialUpdateTask: Task<Void, Never>?
    /// Хранилище справочника со странами/городами
    private let swStorage = FileManager991(fileName: "CountriesAndCities.json")

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
                .accentColor(.swAccent)
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
                        .getSocialUpdates(userID: defaults.mainUserInfo?.userID)
                    defaults.setUserNeedUpdate(!isUpdated)
                }
            default:
                socialUpdateTask?.cancel()
                defaults.setUserNeedUpdate(true)
            }
        }
    }

    private func updateCountriesIfNeeded() {
        guard DateFormatterService.days(from: defaults.lastCountriesUpdateDate, to: .now) > 30 else { return }
        countriesUpdateTask = Task {
            do {
                let countries = try await SWClient(with: defaults).getCountries()
                // TODO: сохранить справочник в json
                defaults.didUpdateCountries()
            } catch {
                // TODO: взять справочник из бандла
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

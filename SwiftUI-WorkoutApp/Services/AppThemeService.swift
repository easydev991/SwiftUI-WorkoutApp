import UIKit

enum AppThemeService {
    enum Theme: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        case dark = "Темная тема"
        case light = "Светлая тема"
        case system = "Как в системе"
    }

    /// Задает выбранную тему для приложения
    ///
    /// - Parameter newTheme: Новая тема
    static func set(_ newTheme: Theme) {
        var userInterfaceStyle: UIUserInterfaceStyle
        switch newTheme {
        case .dark:
            userInterfaceStyle = .dark
        case .light:
            userInterfaceStyle = .light
        case .system:
            userInterfaceStyle = .unspecified
        }
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}

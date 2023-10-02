import SwiftUI
import UIKit

enum AppThemeService {
    enum Theme: Int, CaseIterable, Identifiable {
        var id: Int { rawValue }
        case dark = 0
        case light = 1
        case system = 2

        var localizedKey: LocalizedStringKey {
            switch self {
            case .dark: "Темная тема"
            case .light: "Светлая тема"
            case .system: "Как в системе"
            }
        }
    }

    /// Задает выбранную тему для приложения
    ///
    /// - Parameter newTheme: Новая тема
    static func set(_ newTheme: Theme) {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        keyWindow?.overrideUserInterfaceStyle = switch newTheme {
        case .dark:
            .dark
        case .light:
            .light
        case .system:
            .unspecified
        }
    }
}

import SWModels
import UIKit

enum AppThemeService {
    /// Задает выбранную тему для приложения
    ///
    /// - Parameter newTheme: Новая тема
    static func set(_ newTheme: AppColorTheme) {
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

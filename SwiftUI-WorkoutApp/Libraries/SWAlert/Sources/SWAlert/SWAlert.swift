import SwiftUI
import UIKit

@MainActor
public final class SWAlert {
    public static let shared = SWAlert()
    private var currentAlert: UIViewController?

    /// Показывает системный алерт с заданными параметрами
    /// - Parameters:
    ///   - title: Заголовок. Если передать `nil`, то сообщение выделится жирным. Если передать текст или пустую строку, будет без
    /// заголовка, и сообщение будет со стандартным шрифтом
    ///   - message: Текст сообщения
    ///   - closeButtonTitle: Заголовок кнопки для закрытия алерта
    ///   - closeButtonStyle: Стиль кнопки для закрытия алерта
    ///   - closeButtonTintColor: Цвет кнопки для закрытия алерта. Если не настроить явно, то при появлении будет системный (синий) цвет, а
    /// при нажатии он изменится на `AccentColor` в проекте
    public func presentDefaultUIKit(
        title: String? = "",
        message: String,
        closeButtonTitle: String = "Ok",
        closeButtonStyle: UIAlertAction.Style = .default,
        closeButtonTintColor: UIColor? = .systemGreen
    ) {
        guard currentAlert == nil, let topMostViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = closeButtonTintColor
        alert.addAction(
            .init(
                title: closeButtonTitle,
                style: closeButtonStyle,
                handler: { [weak self] _ in
                    self?.dismiss()
                }
            )
        )
        currentAlert = alert
        topMostViewController.present(alert, animated: true)
    }

    private func dismiss() {
        currentAlert?.dismiss(animated: true)
        currentAlert = nil
    }

    private var topMostViewController: UIViewController? {
        UIApplication.shared.firstKeyWindow?.rootViewController?.topMostViewController
    }
}

private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: \.isKeyWindow)
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        return self
    }
}

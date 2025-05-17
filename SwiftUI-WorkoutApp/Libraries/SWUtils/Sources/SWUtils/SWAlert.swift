import SwiftUI
import UIKit

@MainActor
public final class SWAlert {
    public static let shared = SWAlert()
    private var currentAlert: UIViewController?

    /// Показывает системный алерт с заданными параметрами
    /// - Parameters:
    ///   - title: Заголовок. Если передать `nil`, то сообщение выделится жирным. Если передать текст или пустую строку,
    ///   будет без заголовка, и сообщение будет со стандартным шрифтом
    ///   - message: Текст сообщения
    ///   - closeButtonTitle: Заголовок кнопки для закрытия алерта
    ///   - closeButtonStyle: Стиль кнопки для закрытия алерта
    public func presentDefaultUIKit(
        title: String? = "",
        message: String,
        closeButtonTitle: String = "Ok",
        closeButtonStyle: UIAlertAction.Style = .default,
        completion: (() -> Void)? = nil
    ) {
        guard currentAlert == nil, let topMostViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            .init(
                title: closeButtonTitle,
                style: closeButtonStyle,
                handler: { [weak self] _ in
                    self?.dismiss(completion: completion)
                }
            )
        )
        currentAlert = alert
        topMostViewController.present(alert, animated: true)
    }

    /// Показывает стандартный алерт с сообщение об ошибке
    ///
    /// Игнорирует `CancellationError`
    public func presentDefaultUIKit(_ error: Error) {
        guard type(of: error) != CancellationError.self else {
            // Баг в NavigationView + searchable приводит к ошибке отмены,
            // если сначала нажать на поле поиска, а следующий модальный
            // экран закрыть свайпом вниз. Будет исправлено переходом
            // на iOS 16 min + NavigationStack
            return
        }
        presentDefaultUIKit(message: error.localizedDescription)
    }

    /// Показывает алерт об отсутствии интернета
    /// - Parameter isConnected: Состояние подключения к сети
    /// - Returns: `true` - нужно показать алерт (нет сети), `false` - алерт не нужен (сеть есть)
    @discardableResult
    public func presentNoConnection(_ isConnected: Bool) -> Bool {
        let showAlert = !isConnected
        if showAlert {
            presentDefaultUIKit(
                title: NSLocalizedString(
                    "Error.NoConnectionTitle",
                    bundle: .module,
                    comment: "Нет соединения с сетью"
                ),
                message: NSLocalizedString(
                    "Error.NoConnectionMessage",
                    bundle: .module,
                    comment: "Не удалось загрузить данные. Проверьте подключение к интернету."
                )
            )
        }
        return showAlert
    }

    private func dismiss(completion: (() -> Void)? = nil) {
        currentAlert?.dismiss(animated: true, completion: completion)
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

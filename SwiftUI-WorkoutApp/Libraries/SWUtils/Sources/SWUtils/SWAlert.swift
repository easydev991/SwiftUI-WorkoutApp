import SwiftUI
import UIKit

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
    public nonisolated func presentDefaultUIKit(
        title: String? = "",
        message: String,
        closeButtonTitle: String = "Ok",
        closeButtonStyle: UIAlertAction.Style = .default
    ) {
        Task { @MainActor in
            guard currentAlert == nil, let topMostViewController else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    public nonisolated func presentNoConnection(_ isConnected: Bool) -> Bool {
        let showAlert = !isConnected
        if showAlert {
            presentDefaultUIKit(
                title: NSLocalizedString("Нет соединения с сетью", comment: ""),
                message: NSLocalizedString("Проверьте подключение и повторите попытку", comment: "")
            )
        }
        return showAlert
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

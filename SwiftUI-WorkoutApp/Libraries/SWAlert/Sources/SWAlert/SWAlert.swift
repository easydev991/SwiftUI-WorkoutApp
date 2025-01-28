import UIKit

@MainActor
public final class SWAlert {
    public static let shared = SWAlert()
    private var alertController: UIAlertController?

    public nonisolated func present(
        title: String? = "",
        message: String,
        closeButtonTitle: String = "Ok",
        closeButtonStyle: UIAlertAction.Style = .default
    ) {
        Task { @MainActor in
            guard alertController == nil else { return }
            guard let topMostViewController else { return }
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.view.tintColor = .systemGreen // иначе при появлении цвет будет дефолтный
            alert.addAction(
                .init(
                    title: closeButtonTitle,
                    style: closeButtonStyle,
                    handler: { [weak self] _ in
                        guard let self else { return }
                        alertController = nil
                    }
                )
            )
            alertController = alert
            topMostViewController.present(alert, animated: true)
        }
    }

    public nonisolated func dismiss() {
        Task { @MainActor in
            alertController?.dismiss(animated: true)
            alertController = nil
        }
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

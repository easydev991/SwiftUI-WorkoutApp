import UIKit.UIApplication

public enum URLOpener {
    @MainActor
    public static func open(_ url: URL?) {
        if let url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

import UIKit

enum URLOpener {
    @MainActor
    static func open(_ url: URL?) {
        if let url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

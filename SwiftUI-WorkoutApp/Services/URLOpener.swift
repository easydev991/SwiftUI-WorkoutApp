import UIKit

protocol URLOpener {
    /// Открывает указанный `URL`
    func open(_ url: URL)
}

struct URLOpenerImp: URLOpener {
    func open(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

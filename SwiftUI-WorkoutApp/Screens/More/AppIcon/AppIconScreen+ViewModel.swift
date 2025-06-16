import Foundation
import OSLog
import UIKit.UIApplication

extension AppIconScreen {
    @MainActor
    final class ViewModel: ObservableObject {
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: ViewModel.self)
        )
        @Published private(set) var currentAppIcon: IconVariant

        init() {
            if let currentIconName = UIApplication.shared.alternateIconName {
                self.currentAppIcon = IconVariant(name: currentIconName)
            } else {
                self.currentAppIcon = .primary
            }
        }

        func setIcon(_ icon: IconVariant) async {
            do {
                guard UIApplication.shared.supportsAlternateIcons else {
                    throw IconError.alternateIconsNotSupported
                }
                guard icon.alternateName != UIApplication.shared.alternateIconName else { return }
                try await UIApplication.shared.setAlternateIconName(icon.alternateName)
                currentAppIcon = icon
                logger.info("Установили иконку: \(icon.rawValue)")
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
    }
}

extension AppIconScreen.ViewModel {
    enum IconError: Error, LocalizedError {
        case alternateIconsNotSupported

        var errorDescription: String? {
            switch self {
            case .alternateIconsNotSupported:
                "Альтернативные иконки не поддерживаются"
            }
        }
    }
}

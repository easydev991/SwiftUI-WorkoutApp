import SwiftUI
import UIKit

extension ThemeIconScreen {
    enum IconVariant: String, CaseIterable {
        case primary = "AppIcon"
        case one = "AppIcon1"
        case two = "AppIcon2"
        case three = "AppIcon3"
        case four = "AppIcon4"
        case five = "AppIcon5"
        case six = "AppIcon6"
        case seven = "AppIcon7"
        case eight = "AppIcon8"
        case nine = "AppIcon9"
        case ten = "AppIcon10"

        /// Название альтернативной иконки, для дефолтной иконки всегда `nil`
        var alternateName: String? {
            switch self {
            case .primary: nil
            default: rawValue
            }
        }

        /// Уменьшенная картинка (обычный ассет) для отображения в списке
        var listImage: Image {
            let firstPart = rawValue
            let fullName = "\(firstPart)Small"
            return Image(fullName)
        }

        @MainActor
        var isSelected: Bool {
            alternateName == UIApplication.shared.alternateIconName
        }

        init(name: String?) {
            self = IconVariant(rawValue: name ?? "") ?? .primary
        }
    }
}

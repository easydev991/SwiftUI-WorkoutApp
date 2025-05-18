import Foundation

/// Размер площадки
public enum ParkSize: Int, CaseIterable, CustomStringConvertible {
    case small = 1
    case medium = 2
    case large = 3

    public init(rawValue: Int) {
        switch rawValue {
        case 1: self = .small
        case 2: self = .medium
        default: self = .large
        }
    }

    public var description: String {
        switch self {
        case .small: NSLocalizedString("ParkSize.Small", bundle: .module, comment: "")
        case .medium: NSLocalizedString("ParkSize.Medium", bundle: .module, comment: "")
        case .large: NSLocalizedString("ParkSize.Large", bundle: .module, comment: "")
        }
    }
}

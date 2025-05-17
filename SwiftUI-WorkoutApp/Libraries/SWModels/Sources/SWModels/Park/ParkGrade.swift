import Foundation

/// Тип/класс площадки
public enum ParkGrade: Int, CaseIterable, CustomStringConvertible {
    case soviet = 1
    case modern = 2
    case collars = 3
    case legendary = 6

    public init(rawValue: Int) {
        switch rawValue {
        case 1: self = .soviet
        case 2: self = .modern
        case 3: self = .collars
        default: self = .legendary
        }
    }

    public var description: String {
        switch self {
        case .collars: NSLocalizedString("ParkGrade.Collars", bundle: .module, comment: "")
        case .modern: NSLocalizedString("ParkGrade.Modern", bundle: .module, comment: "")
        case .soviet: NSLocalizedString("ParkGrade.Soviet", bundle: .module, comment: "")
        case .legendary: NSLocalizedString("ParkGrade.Legendary", bundle: .module, comment: "")
        }
    }
}

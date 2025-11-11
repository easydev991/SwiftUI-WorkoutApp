import Foundation

/// Тип/класс площадки
public enum ParkGrade: Int, CaseIterable, CustomStringConvertible, Codable {
    case soviet = 1
    case modern = 2
    case collars = 3
    case legendary = 6

    public init(code: Int) {
        switch code {
        case 1: self = .soviet
        case 2: self = .modern
        case 3: self = .collars
        default: self = .legendary
        }
    }

    public var description: String {
        switch self {
        case .collars: String(localized: .parkGradeCollars)
        case .modern: String(localized: .parkGradeModern)
        case .soviet: String(localized: .parkGradeSoviet)
        case .legendary: String(localized: .parkGradeLegendary)
        }
    }
}

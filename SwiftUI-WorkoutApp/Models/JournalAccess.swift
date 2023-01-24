import Foundation

enum JournalAccess: Int, CaseIterable, CustomStringConvertible {
    case all = 0
    case friends = 1
    case nobody = 2

    init(_ rawValue: Int?) {
        switch rawValue {
        case 0: self = .all
        case 1: self = .friends
        case 2: self = .nobody
        default: self = .all
        }
    }

    var description: String {
        switch self {
        case .all: return "Все"
        case .friends: return "Друзья"
        case .nobody: return "Только я"
        }
    }
}

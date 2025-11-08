import Foundation

/// Действие с другом (добавить/удалить)
public enum FriendAction: CustomStringConvertible, Equatable, Sendable {
    case add
    case remove

    public var description: String {
        switch self {
        case .add: String(localized: .friendActionAdd)
        case .remove: String(localized: .friendActionRemove)
        }
    }
}

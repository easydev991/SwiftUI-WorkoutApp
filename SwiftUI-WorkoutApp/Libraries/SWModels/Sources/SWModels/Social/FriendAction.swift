import Foundation

/// Действие с другом (добавить/удалить)
public enum FriendAction: CustomStringConvertible, Equatable, Sendable {
    case add
    case remove

    public var description: String {
        switch self {
        case .add: NSLocalizedString("FriendAction.Add", bundle: .module, comment: "")
        case .remove: NSLocalizedString("FriendAction.Remove", bundle: .module, comment: "")
        }
    }
}

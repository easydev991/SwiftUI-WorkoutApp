import Foundation

public enum BlacklistOption: Sendable {
    case add
    case remove
}

public extension BlacklistOption {
    var title: String {
        switch self {
        case .add: NSLocalizedString("BlacklistOption.Block.title", bundle: .module, comment: "")
        case .remove: NSLocalizedString("BlacklistOption.Unblock.title", bundle: .module, comment: "")
        }
    }

    var dialogTitle: String {
        switch self {
        case .add: NSLocalizedString("BlacklistOption.Block.dialogTitle", bundle: .module, comment: "")
        case .remove: NSLocalizedString("BlacklistOption.Unblock.dialogTitle", bundle: .module, comment: "")
        }
    }

    var dialogMessage: String {
        switch self {
        case .add: NSLocalizedString("BlacklistOption.Block.dialogMessage", bundle: .module, comment: "")
        case .remove: NSLocalizedString("BlacklistOption.Unblock.dialogMessage", bundle: .module, comment: "")
        }
    }

    var result: String {
        switch self {
        case .add: NSLocalizedString("BlacklistOption.Block.result", bundle: .module, comment: "")
        case .remove: NSLocalizedString("BlacklistOption.Unblock.result", bundle: .module, comment: "")
        }
    }
}

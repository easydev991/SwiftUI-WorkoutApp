import Foundation

public enum BlacklistOption: Sendable {
    case add
    case remove
}

public extension BlacklistOption {
    var title: String {
        switch self {
        case .add: String(localized: .blacklistOptionBlockTitle)
        case .remove: String(localized: .blacklistOptionUnblockTitle)
        }
    }

    var dialogTitle: String {
        switch self {
        case .add: String(localized: .blacklistOptionBlockDialogTitle)
        case .remove: String(localized: .blacklistOptionUnblockDialogTitle)
        }
    }

    var dialogMessage: String {
        switch self {
        case .add: String(localized: .blacklistOptionBlockDialogMessage)
        case .remove: String(localized: .blacklistOptionUnblockDialogMessage)
        }
    }

    var result: String {
        switch self {
        case .add: String(localized: .blacklistOptionBlockResult)
        case .remove: String(localized: .blacklistOptionUnblockResult)
        }
    }
}

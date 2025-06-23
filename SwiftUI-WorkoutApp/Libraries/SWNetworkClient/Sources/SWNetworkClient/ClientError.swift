import Foundation

public enum ClientError: Error, LocalizedError {
    case forceLogout
    case noConnection
    case notFound

    public var errorDescription: String? {
        switch self {
        case .forceLogout:
            NSLocalizedString("ClientError.ForceLogout", bundle: .module, comment: "")
        case .noConnection:
            NSLocalizedString("ClientError.NoConnection", bundle: .module, comment: "")
        case .notFound:
            NSLocalizedString("ClientError.NotFound", bundle: .module, comment: "")
        }
    }
}

import Foundation

public enum ClientError: Error, LocalizedError {
    case forceLogout
    case noConnection

    public var errorDescription: String? {
        switch self {
        case .forceLogout:
            NSLocalizedString("ClientError.ForceLogout", bundle: .module, comment: "")
        case .noConnection:
            NSLocalizedString("ClientError.NoConnection", bundle: .module, comment: "")
        }
    }
}

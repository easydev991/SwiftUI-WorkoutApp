import Foundation

public enum ClientError: Error, LocalizedError {
    case forceLogout

    public var errorDescription: String? {
        switch self {
        case .forceLogout: "Для корректной работы приложения нужен повторный вход"
        }
    }
}

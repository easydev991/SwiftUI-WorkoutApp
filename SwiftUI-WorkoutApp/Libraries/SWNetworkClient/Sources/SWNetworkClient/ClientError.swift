import Foundation

enum ClientError: Error, LocalizedError {
    case forceLogout

    var errorDescription: String? {
        switch self {
        case .forceLogout: "Для корректной работы приложения нужен повторный вход"
        }
    }
}

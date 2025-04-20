import Foundation

public enum ClientError: Error, LocalizedError {
    case forceLogout
    case noConnection

    public var errorDescription: String? {
        switch self {
        case .forceLogout: "Для корректной работы приложения нужен повторный вход"
        case .noConnection: "Не удалось загрузить данные. Проверьте подключение к интернету."
        }
    }
}

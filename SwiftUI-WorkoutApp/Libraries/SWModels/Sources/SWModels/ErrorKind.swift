import Foundation

/// Тип ошибки для экранов
public enum ErrorKind: Equatable {
    /// Нет подключения к сети
    case notConnected
    /// Другая ошибка
    case common(message: String)
}

import Combine
import Foundation

@MainActor
public protocol AuthHelper: Sendable {
    /// Токен авторизации для запросов к серверу
    var authToken: String? { get }
    /// Publisher для отслеживания изменений токена
    var authTokenPublisher: AnyPublisher<String?, Never> { get }
    /// Логаут с удалением всех данных пользователя
    func triggerLogout()
}

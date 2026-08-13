import Foundation
import SWModels
import SWNetwork

/// Протокол для авторизации и регистрации
public protocol AuthClient: Sendable {
    /// Выполняет авторизацию
    /// - Parameter token: Токен авторизации
    /// - Returns: `id` авторизованного пользователя
    func logIn(with token: String?) async throws -> Int

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func resetPassword(for login: String) async throws -> Bool
}

extension SWClient: AuthClient {
    public func logIn(with token: String?) async throws -> Int {
        let endpoint = Endpoint.login
        let result: LoginResponse = try await makeResult(for: endpoint, with: token)
        return result.userId
    }

    public func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response: LoginResponse = try await makeResult(for: endpoint)
        return response.userId != .zero
    }
}

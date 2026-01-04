import Foundation
import SWModels
import SWNetwork

/// Протокол для авторизации и регистрации
public protocol AuthClient: Sendable {
    /// Выполняет регистрацию пользователя
    ///
    /// Приложение не пропускают в `appstore`, пока на бэке поля "пол" и "дата рождения" являются обязательными,
    /// поэтому этот запрос не используется
    /// - Parameter model: необходимые для регистрации данные
    @available(*, deprecated, message: "Запрос не используется, т.к. регистрация в приложении отключена")
    func registration(with model: MainUserForm) async throws

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
    public func registration(with model: MainUserForm) async throws {
        let endpoint = Endpoint.registration(form: model)
        try await makeStatus(for: endpoint)
    }

    public func logIn(with token: String?) async throws -> Int {
        let endpoint = Endpoint.login
        let finalComponents = try await makeComponents(for: endpoint, with: token)
        let result: LoginResponse = try await service.requestData(components: finalComponents)
        return result.userId
    }

    public func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response: LoginResponse = try await makeResult(for: endpoint)
        return response.userId != .zero
    }
}

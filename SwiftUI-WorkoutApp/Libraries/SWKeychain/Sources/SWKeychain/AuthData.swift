import Foundation

public struct AuthData: Codable {
    /// Логин
    ///
    /// Нужен для генерации токена
    let login: String
    /// Пароль
    ///
    /// - Нужен для генерации токена
    /// - Используется при смене логина, когда нужно сгенерировать новый токен, чтобы не выбросило из аккаунта
    public let password: String
    /// Токен авторизации, который отправляем на сервер
    public var token: String? {
        guard [login, password].allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return nil
        }
        return (login + ":" + password).data(using: .utf8)?.base64EncodedString()
    }

    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}

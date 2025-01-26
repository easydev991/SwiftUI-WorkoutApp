/// Используется во всех запросах, где нужна авторизация
public struct AuthData: Codable {
    /// Используем для генерации токена
    ///
    /// Например, при смене логина нужно сгенерировать новый токен, чтобы не выбросило из аккаунта - вот тут и используем этот пароль
    public let password: String
    /// Отправляем на сервер
    public let token: String?

    public init(login: String, password: String) {
        self.token = (login + ":" + password).data(using: .utf8)?.base64EncodedString()
        self.password = password
    }
}

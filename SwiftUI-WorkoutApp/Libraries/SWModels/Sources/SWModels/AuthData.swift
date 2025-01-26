/// Используется во всех запросах, где нужна авторизация
public struct AuthData: Codable {
    public let login: String
    public let token: String?

    public init(login: String, password: String) {
        self.login = login
        self.token = (login + ":" + password).data(using: .utf8)?.base64EncodedString()
    }

    public init(login: String, token: String?) {
        self.login = login
        self.token = token
    }
}

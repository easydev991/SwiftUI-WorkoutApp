/// Используется во всех запросах, где нужна авторизация
public struct AuthData: Codable {
    public let login, password: String

    public var base64Encoded: String? {
        (login + ":" + password).data(using: .utf8)?.base64EncodedString()
    }

    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}

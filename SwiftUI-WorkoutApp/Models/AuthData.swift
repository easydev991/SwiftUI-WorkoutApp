import Foundation

/// Используется во всех запросах, где нужна авторизация
struct AuthData: Codable {
    let login, password: String

    var base64Encoded: String? {
        (login + ":" + password).data(using: .utf8)?.base64EncodedString()
    }
}

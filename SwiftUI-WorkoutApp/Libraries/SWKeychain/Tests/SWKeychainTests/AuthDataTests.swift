@testable import SWKeychain
import Testing

struct AuthDataTests {
    private static let validLogin = "user@domain.com"
    private static let validPassword = "p@ss!123"

    @Test
    func validCredentialsGenerateCorrectToken() throws {
        let login = Self.validLogin
        let password = Self.validPassword
        let model = AuthData(login: login, password: password)
        let token = try #require(model.token)
        #expect(model.login == login)
        #expect(model.password == password)
        #expect(token == "dXNlckBkb21haW4uY29tOnBAc3MhMTIz")
    }

    @Test(arguments: [
        ("", Self.validPassword),
        (Self.validLogin, ""),
        ("", ""),
        (" ", Self.validPassword),
        (Self.validLogin, " "),
        ("   ", "   ")
    ])
    func invalidCredentialsProduceNilToken(login: String, password: String) {
        let model = AuthData(login: login, password: password)
        #expect(model.token == nil)
    }
}

@testable import SWModels
import Testing

struct LoginCredentialsTests {
    @Test
    func initializationWithDefaultValues() {
        let credentials = LoginCredentials()
        #expect(credentials.login == "")
        #expect(credentials.password == "")
        #expect(credentials.minPasswordSize == Constants.minPasswordSize)
    }

    @Test
    func initializationWithCustomParameters() {
        let credentials = LoginCredentials(
            login: "test@mail.com",
            password: "qwerty",
            minPasswordSize: 5
        )
        #expect(credentials.login == "test@mail.com")
        #expect(credentials.password == "qwerty")
        #expect(credentials.minPasswordSize == 5)
    }

    // MARK: - isReady

    @Test
    func isReady_AllFieldsEmpty() {
        let credentials = LoginCredentials()
        #expect(!credentials.isReady)
    }

    @Test
    func isReady_LoginNotEmptyPasswordTooShort() {
        let credentials = LoginCredentials(login: "user", password: "12345")
        #expect(!credentials.isReady)
    }

    @Test
    func isReady_ValidLoginAndExactMinPassword() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(credentials.isReady)
    }

    @Test
    func isReady_PasswordWithSpacesMeetingMinLength() {
        let credentials = LoginCredentials(login: "user", password: "12 345 6")
        #expect(credentials.isReady)
    }

    @Test
    func isReady_PasswordWithSpacesBelowMinLength() {
        let credentials = LoginCredentials(login: "user", password: "123 45")
        #expect(!credentials.isReady)
    }

    @Test
    func isReady_CustomMinPasswordSizeValidation() {
        let credentials = LoginCredentials(
            login: "user",
            password: "1234",
            minPasswordSize: 4
        )
        #expect(credentials.isReady)

        let credentials2 = LoginCredentials(
            login: "user",
            password: "123",
            minPasswordSize: 4
        )
        #expect(!credentials2.isReady)
    }

    // MARK: - canRestorePassword

    @Test
    func canRestorePassword_EmptyLogin() {
        let credentials = LoginCredentials(login: "")
        #expect(!credentials.canRestorePassword)
    }

    @Test
    func canRestorePassword_NonEmptyLogin() {
        let credentials = LoginCredentials(login: " ")
        #expect(credentials.canRestorePassword)

        let credentials2 = LoginCredentials(login: "user@mail.com")
        #expect(credentials2.canRestorePassword)
    }

    // MARK: - canLogIn

    @Test
    func canLogIn_AllConditionsMet() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(credentials.canLogIn(isError: false))
    }

    @Test
    func canLogIn_WhenNotReady() {
        let credentials = LoginCredentials(login: "user", password: "123")
        #expect(!credentials.canLogIn(isError: false))
    }

    @Test
    func canLogIn_WithError() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(!credentials.canLogIn(isError: true))
    }
}

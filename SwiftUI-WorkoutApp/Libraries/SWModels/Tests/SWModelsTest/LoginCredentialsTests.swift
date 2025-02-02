@testable import SWModels
import Testing

struct LoginCredentialsTests {
    @Test
    func testInitializationWithDefaultValues() {
        let credentials = LoginCredentials()
        #expect(credentials.login == "")
        #expect(credentials.password == "")
        #expect(credentials.minPasswordSize == Constants.minPasswordSize)
    }

    @Test
    func testInitializationWithCustomParameters() {
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
    func testIsReady_AllFieldsEmpty() {
        let credentials = LoginCredentials()
        #expect(!credentials.isReady)
    }

    @Test
    func testIsReady_LoginNotEmptyPasswordTooShort() {
        let credentials = LoginCredentials(login: "user", password: "12345")
        #expect(!credentials.isReady)
    }

    @Test
    func testIsReady_ValidLoginAndExactMinPassword() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(credentials.isReady)
    }

    @Test
    func testIsReady_PasswordWithSpacesMeetingMinLength() {
        let credentials = LoginCredentials(login: "user", password: "12 345 6")
        #expect(credentials.isReady)
    }

    @Test
    func testIsReady_PasswordWithSpacesBelowMinLength() {
        let credentials = LoginCredentials(login: "user", password: "123 45")
        #expect(!credentials.isReady)
    }

    @Test
    func testIsReady_CustomMinPasswordSizeValidation() {
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
    func testCanRestorePassword_EmptyLogin() {
        let credentials = LoginCredentials(login: "")
        #expect(!credentials.canRestorePassword)
    }

    @Test
    func testCanRestorePassword_NonEmptyLogin() {
        let credentials = LoginCredentials(login: " ")
        #expect(credentials.canRestorePassword)

        let credentials2 = LoginCredentials(login: "user@mail.com")
        #expect(credentials2.canRestorePassword)
    }

    // MARK: - canLogIn

    @Test
    func testCanLogIn_AllConditionsMet() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(credentials.canLogIn(isError: false, isNetworkConnected: true))
    }

    @Test
    func testCanLogIn_WhenNotReady() {
        let credentials = LoginCredentials(login: "user", password: "123")
        #expect(!credentials.canLogIn(isError: false, isNetworkConnected: true))
    }

    @Test
    func testCanLogIn_WithError() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(!credentials.canLogIn(isError: true, isNetworkConnected: true))
    }

    @Test
    func testCanLogIn_NoNetwork() {
        let credentials = LoginCredentials(login: "user", password: "123456")
        #expect(!credentials.canLogIn(isError: false, isNetworkConnected: false))
    }

    @Test
    func testCanLogIn_MultipleIssues() {
        let credentials = LoginCredentials(login: "user", password: "123")
        #expect(!credentials.canLogIn(isError: true, isNetworkConnected: false))
    }
}

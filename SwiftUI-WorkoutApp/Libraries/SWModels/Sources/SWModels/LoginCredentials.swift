import Foundation

/// Модель для экрана авторизации
public struct LoginCredentials: Equatable {
    public var login: String
    public var password: String
    let minPasswordSize: Int

    public init(
        login: String = "",
        password: String = "",
        minPasswordSize: Int = Constants.minPasswordSize
    ) {
        self.login = login
        self.password = password
        self.minPasswordSize = minPasswordSize
    }

    public var isReady: Bool {
        !login.isEmpty && password.trueCount >= minPasswordSize
    }

    public var canRestorePassword: Bool { !login.isEmpty }

    public func canLogIn(isError: Bool, isNetworkConnected: Bool) -> Bool {
        isReady && !isError && isNetworkConnected
    }
}

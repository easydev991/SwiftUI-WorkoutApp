import Foundation
import SWModels

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var login = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var showForgotPasswordAlert = false
    @Published private(set) var showResetSuccessfulAlert = false
    @Published private(set) var errorMessage = ""

    func loginAction(with defaults: DefaultsProtocol) async {
        if !canLogIn { return }
        isLoading.toggle()
        do {
            try await APIService(with: defaults, canForceLogout: false).logInWith(login, password)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func forgotPasswordTapped(with defaults: DefaultsProtocol) async {
        guard canRestorePassword else {
            showForgotPasswordAlert = true
            return
        }
        isLoading.toggle()
        do {
            showResetSuccessfulAlert = try await APIService(with: defaults, needAuth: false).resetPassword(for: login)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func warningAlertClosed() {
        showForgotPasswordAlert = false
    }

    func resetSuccessfulAlertClosed() {
        showResetSuccessfulAlert = false
    }

    func clearErrorMessage() { errorMessage = "" }
}

extension LoginViewModel {
    var canLogIn: Bool {
        !login.isEmpty
            && password.count >= Constants.minPasswordSize
    }

    var canRestorePassword: Bool { !login.isEmpty }
}

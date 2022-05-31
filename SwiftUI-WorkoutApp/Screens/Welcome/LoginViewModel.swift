import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var login = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var showForgotPasswordAlert = false
    @Published private(set) var showResetSuccessfulAlert = false
    @Published private(set) var errorMessage = ""

    var canLogIn: Bool {
        !login.isEmpty && password.count >= Constants.minPasswordSize
    }

    var canRestorePassword: Bool { !login.isEmpty }

    func clearErrorMessage() { errorMessage = "" }

    func warningAlertClosed() {
        showForgotPasswordAlert = false
    }

    func resetSuccessfulAlertClosed() {
        showResetSuccessfulAlert = false
    }

    func loginAction(with userDefaults: DefaultsService) async {
        if !canLogIn { return }
        isLoading.toggle()
        do {
            try await APIService(with: userDefaults).logInWith(login, password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func forgotPasswordTapped(with defaults: DefaultsService) async {
        if canRestorePassword {
            isLoading.toggle()
            do {
                showResetSuccessfulAlert = try await APIService(with: defaults).resetPassword(for: login)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading.toggle()
        } else {
            showForgotPasswordAlert = true
        }
    }
}

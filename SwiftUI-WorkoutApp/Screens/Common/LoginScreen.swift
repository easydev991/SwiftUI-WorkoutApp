import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран для авторизации / восстановления пароля
struct LoginScreen: View {
    @EnvironmentObject private var defaults: DefaultsService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @State private var isLoading = false
    @State private var credentials = LoginCredentials()
    @State private var resetErrorMessage = ""
    @State private var loginErrorMessage = ""
    @State private var loginTask: Task<Void, Never>?
    @State private var resetPasswordTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?
    private var client: SWClient { SWClient(with: defaults) }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                loginField
                passwordField
            }
            Spacer()
            VStack(spacing: 12) {
                loginButton
                forgotPasswordButton
            }
        }
        .padding(.top, 22)
        .padding([.horizontal, .bottom])
        .loadingOverlay(if: isLoading)
        .interactiveDismissDisabled(isLoading)
        .background(Color.swBackground)
        .onChange(of: credentials) { _ in clearErrorMessages() }
        .onDisappear(perform: cancelTasks)
    }
}

private extension LoginScreen {
    enum FocusableField: Hashable {
        case username, password
    }

    var isError: Bool {
        !loginErrorMessage.isEmpty || !resetErrorMessage.isEmpty
    }

    var canLogIn: Bool {
        credentials.canLogIn(isError: isError, isNetworkConnected: isNetworkConnected)
    }

    var loginField: some View {
        SWTextField(
            placeholder: "Логин или email",
            text: $credentials.login,
            isFocused: focus == .username,
            errorState: isError ? .message(resetErrorMessage) : nil
        )
        .focused($focus, equals: .username)
        .onAppear(perform: showKeyboard)
        .accessibilityIdentifier("loginField")
    }

    func showKeyboard() {
        guard focus == nil else { return }
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            focus = .username
        }
    }

    var passwordField: some View {
        SWTextField(
            placeholder: "Пароль",
            text: $credentials.password,
            isSecure: true,
            isFocused: focus == .password,
            errorState: !loginErrorMessage.isEmpty ? .message(loginErrorMessage) : nil
        )
        .focused($focus, equals: .password)
        .onSubmit(loginAction)
        .accessibilityIdentifier("passwordField")
    }

    var loginButton: some View {
        Button("Войти", action: loginAction)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .disabled(!canLogIn)
            .accessibilityIdentifier("loginButton")
    }

    var forgotPasswordButton: some View {
        Button("Восстановить пароль", action: forgotPasswordAction)
            .tint(.swMainText)
    }

    func loginAction() {
        guard !isLoading else { return }
        focus = nil
        isLoading = true
        loginTask = Task {
            do {
                let token = AuthData(login: credentials.login, password: credentials.password).token
                let userId = try await client.logIn(with: token)
                try defaults.saveAuthData(login: credentials.login, password: credentials.password)
                let result = try await client.getSocialUpdates(userID: userId)
                try defaults.saveFriendsIds(result.friends.map(\.id))
                try defaults.saveFriendRequests(result.friendRequests)
                try defaults.saveBlacklist(result.blacklist)
                try defaults.saveUserInfo(result.user)
            } catch {
                loginErrorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func forgotPasswordAction() {
        guard credentials.canRestorePassword else {
            SWAlert.shared.presentDefaultUIKit(
                message: Constants.Alert.forgotPassword.localized
            )
            return
        }
        clearErrorMessages()
        isLoading.toggle()
        resetPasswordTask = Task {
            do {
                if try await SWClient(with: defaults).resetPassword(for: credentials.login) {
                    SWAlert.shared.presentDefaultUIKit(
                        title: "Готово".localized,
                        message: Constants.Alert.resetSuccessful.localized
                    )
                }
            } catch {
                resetErrorMessage = error.localizedDescription
            }
            isLoading.toggle()
        }
        focus = credentials.canRestorePassword ? nil : .username
    }

    func clearErrorMessages() {
        loginErrorMessage = ""
        resetErrorMessage = ""
    }

    func cancelTasks() {
        [loginTask, resetPasswordTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    LoginScreen()
}
#endif

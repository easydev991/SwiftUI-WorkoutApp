import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран для авторизации
///
/// На нем еще можно восстановить пароль
struct LoginView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var network: NetworkStatus
    @State private var isLoading = false
    @State private var credentials = Credentials()
    @State private var showResetInfoAlert = false
    @State private var showResetSuccessfulAlert = false
    @State private var errorMessage = ""
    @State private var loginTask: Task<Void, Never>?
    @State private var resetPasswordTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

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
        .onChange(of: credentials) { _ in errorMessage = "" }
        .alert(.init(Constants.Alert.resetSuccessful), isPresented: $showResetSuccessfulAlert) {
            Button("Ok") { showResetSuccessfulAlert = false }
        }
        .onDisappear(perform: cancelTasks)
    }
}

private extension LoginView {
    struct Credentials: Equatable {
        var login = ""
        var password = ""

        var isReady: Bool {
            !login.isEmpty
                && password.trueCount >= Constants.minPasswordSize
        }

        var canRestorePassword: Bool { !login.isEmpty }
    }

    enum FocusableField: Hashable {
        case username, password
    }

    var isError: Bool { !errorMessage.isEmpty }

    var canLogIn: Bool {
        credentials.isReady && !isError && network.isConnected
    }

    var loginField: some View {
        SWTextField(
            placeholder: "Логин или email",
            text: $credentials.login,
            isFocused: focus == .username,
            errorState: isError ? .noMessage : nil
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
            errorState: isError ? .message(errorMessage) : nil
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
            .alert(.init(Constants.Alert.forgotPassword), isPresented: $showResetInfoAlert) {
                Button("Ok") { showResetInfoAlert = false }
            }
    }

    func loginAction() {
        guard !isLoading else { return }
        focus = nil
        isLoading.toggle()
        loginTask = Task {
            do {
                try await SWClient(with: defaults, canForceLogout: false)
                    .logInWith(credentials.login, credentials.password)
            } catch {
                errorMessage = ErrorFilter.message(from: error)
            }
            isLoading.toggle()
        }
    }

    func forgotPasswordAction() {
        guard credentials.canRestorePassword else {
            showResetInfoAlert = true
            return
        }
        isLoading.toggle()
        resetPasswordTask = Task {
            do {
                showResetSuccessfulAlert = try await SWClient(with: defaults, needAuth: false)
                    .resetPassword(for: credentials.login)
            } catch {
                errorMessage = ErrorFilter.message(from: error)
            }
            isLoading.toggle()
        }
        focus = credentials.canRestorePassword ? nil : .username
    }

    func cancelTasks() {
        [loginTask, resetPasswordTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
#Preview {
    LoginView()
        .environmentObject(NetworkStatus())
}
#endif

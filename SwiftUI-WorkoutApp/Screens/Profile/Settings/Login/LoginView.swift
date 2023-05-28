import SwiftUI
import SWModels

/// Экран для авторизации/восстановления пароля
struct LoginView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = LoginViewModel()
    // Вызывает утечку памяти, если разместить внутри viewModel
    @State private var showResetInfoAlert = false
    @State private var showResetSuccessfulAlert = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var loginTask: Task<Void, Never>?
    @State private var resetPasswordTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            Section {
                loginField
                passwordField
            }
            Section {
                loginButton
                forgotPasswordButton
            }
        }
        .loadingOverlay(if: viewModel.isLoading)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok") { viewModel.clearErrorMessage() }
        }
        .alert(Constants.Alert.resetSuccessful, isPresented: $showResetSuccessfulAlert) {
            Button("Ok") { viewModel.resetSuccessfulAlertClosed() }
        }
        .onChange(of: viewModel.showResetSuccessfulAlert, perform: showResetSuccessfulAlert)
        .onChange(of: viewModel.showForgotPasswordAlert, perform: showResetInfoAlert)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onDisappear(perform: cancelTasks)
        .navigationTitle("Авторизация")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension LoginView {
    enum FocusableField: Hashable {
        case username, password
    }

    var loginField: some View {
        TextFieldInForm(
            mode: .regular(systemImageName: "person"),
            placeholder: "Логин или email",
            text: $viewModel.login
        )
        .focused($focus, equals: .username)
        .onAppear(perform: showKeyboard)
        .accessibilityIdentifier("loginField")
    }

    func showKeyboard() {
        guard focus == nil else { return }
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 750_000_000)
            focus = .username
        }
    }

    var passwordField: some View {
        TextFieldInForm(
            mode: .secure,
            placeholder: "Пароль",
            text: $viewModel.password
        )
        .focused($focus, equals: .password)
        .onSubmit(loginAction)
        .accessibilityIdentifier("passwordField")
    }

    var loginButton: some View {
        ButtonInForm("Войти", action: loginAction)
            .disabled(!viewModel.canLogIn)
            .accessibilityIdentifier("loginButton")
    }

    var forgotPasswordButton: some View {
        ButtonInForm("Забыли пароль?", mode: .secondary, action: forgotPasswordAction)
            .alert(Constants.Alert.forgotPassword, isPresented: $showResetInfoAlert) {
                Button("Ok") { viewModel.warningAlertClosed() }
            }
    }

    func loginAction() {
        focus = nil
        loginTask = Task { await viewModel.loginAction(with: defaults) }
    }

    func forgotPasswordAction() {
        resetPasswordTask = Task { await viewModel.forgotPasswordTapped(with: defaults) }
        focus = viewModel.canRestorePassword ? nil : .username
    }

    func showResetInfoAlert(showAlert: Bool) {
        showResetInfoAlert = showAlert
    }

    func showResetSuccessfulAlert(showAlert: Bool) {
        showResetSuccessfulAlert = showAlert
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func cancelTasks() {
        [loginTask, resetPasswordTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(DefaultsService())
    }
}
#endif

import NetworkStatus
import SwiftUI

/// Экран для смены пароля
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = ChangePasswordViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var changePasswordTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            Section("Минимум 6 символов") {
                passwordField
            }
            Section {
                newPasswordField
                newPasswordAgainField
            }
            Section {
                changePasswordButton
            }
        }
        .loadingOverlay(if: viewModel.isLoading)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok") { viewModel.errorAlertClosed() }
        }
        .onChange(of: viewModel.isChangeSuccessful, perform: performLogout)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onDisappear(perform: cancelTask)
        .navigationTitle("Изменить пароль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ChangePasswordView {
    enum FocusableField: Hashable {
        case currentPassword, newPassword, newPasswordAgain
    }

    var passwordField: some View {
        TextFieldInForm(
            mode: .secure,
            placeholder: "Текущий пароль",
            text: $viewModel.currentPasswordText
        )
        .focused($focus, equals: .currentPassword)
        .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        guard focus == nil else { return }
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 750_000_000)
            focus = .currentPassword
        }
    }

    var newPasswordField: some View {
        TextFieldInForm(
            mode: .secure,
            placeholder: "Новый пароль",
            text: $viewModel.newPasswordText
        )
        .focused($focus, equals: .newPassword)
    }

    var newPasswordAgainField: some View {
        TextFieldInForm(
            mode: .secure,
            placeholder: "Новый пароль ещё раз",
            text: $viewModel.newPasswordTextAgain
        )
        .focused($focus, equals: .newPasswordAgain)
    }

    var changePasswordButton: some View {
        ButtonInForm("Сохранить изменения", action: changePasswordTapped)
            .disabled(
                viewModel.isChangeButtonDisabled
                    || !network.isConnected
            )
    }

    func changePasswordTapped() {
        focus = nil
        changePasswordTask = Task { await viewModel.changePasswordAction(with: defaults) }
    }

    func performLogout(needRelogin _: Bool) {
        defaults.triggerLogout()
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func cancelTask() {
        changePasswordTask?.cancel()
    }
}

#if DEBUG
struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(NetworkStatus())
    }
}
#endif

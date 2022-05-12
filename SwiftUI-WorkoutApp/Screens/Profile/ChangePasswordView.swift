//
//  ChangePasswordView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.04.2022.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChangePasswordViewModel()
    @State private var showSuccess = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var changePasswordTask: Task<Void, Never>?
    @FocusState private var focus: FocusableField?

    var body: some View {
        ZStack {
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
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .alert(Constants.Alert.passwordChanged, isPresented: $showSuccess) {
            Button(action: dismissView) { TextOk() }
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: viewModel.errorAlertClosed) { TextOk() }
        }
        .onChange(of: viewModel.isChangeSuccessful, perform: toggleSuccessAlert)
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
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Текущий пароль", text: $viewModel.currentPasswordText)
                .focused($focus, equals: .currentPassword)
        }
        .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            focus = .currentPassword
        }
    }

    var newPasswordField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Новый пароль", text: $viewModel.newPasswordText)
                .focused($focus, equals: .newPassword)
        }
    }

    var newPasswordAgainField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Новый пароль ещё раз", text: $viewModel.newPasswordAgainText)
                .focused($focus, equals: .newPasswordAgain)
        }
    }

    var changePasswordButton: some View {
        Button(action: changePasswordTapped) {
            ButtonInFormLabel(title: "Сохранить изменения")
        }
        .disabled(viewModel.isChangeButtonDisabled)
    }

    func changePasswordTapped() {
        focus = nil
        changePasswordTask = Task { await viewModel.changePasswordAction() }
    }

    func toggleSuccessAlert(showAlert: Bool) {
        showSuccess = showAlert
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func cancelTask() {
        changePasswordTask?.cancel()
    }

    func dismissView() {
        dismiss()
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}

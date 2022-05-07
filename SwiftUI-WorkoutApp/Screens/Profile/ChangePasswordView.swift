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
        .onChange(of: viewModel.isChangeSuccessful) { showSuccess = $0 }
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
        .alert(Constants.Alert.passwordChanged, isPresented: $showSuccess) {
            closeButton
        }
    }

    func changePasswordTapped() {
        focus = nil
        viewModel.changePasswordAction()
    }

    var closeButton: some View {
        Button(role: .cancel) {
            dismiss()
        } label: {
            TextOk()
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}

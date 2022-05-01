//
//  ChangePasswordView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.04.2022.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ChangePasswordViewModel()
    @FocusState private var focus: FocusableField?
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section("Минимум 6 символов") {
                passwordField()
            }
            Section {
                newPasswordField()
                newPasswordAgainField()
            }
            Section {
                changePasswordButton()
            }
        }
        .onChange(of: viewModel.isChangeSuccessful) { isSuccess in
            showSuccess = isSuccess
        }
        .navigationTitle("Изменить пароль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ChangePasswordView {
    enum FocusableField: Hashable {
        case currentPassword, newPassword, newPasswordAgain
    }

    func passwordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Текущий пароль", text: $viewModel.currentPasswordText)
                .focused($focus, equals: .currentPassword)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focus = .currentPassword
            }
        }
    }

    func newPasswordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Новый пароль", text: $viewModel.newPasswordText)
                .focused($focus, equals: .newPassword)
        }
    }

    func newPasswordAgainField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Новый пароль ещё раз", text: $viewModel.newPasswordAgainText)
                .focused($focus, equals: .newPasswordAgain)
        }
    }

    func changePasswordButton() -> some View {
        Button {
            focus = nil
            viewModel.changePasswordAction()
        } label: {
            ButtonInFormLabel(title: "Сохранить изменения")
        }
        .disabled(viewModel.isChangeButtonDisabled)
        .alert("Пароль успешно изменен", isPresented: $showSuccess) {
            Button(role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Ок")
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}

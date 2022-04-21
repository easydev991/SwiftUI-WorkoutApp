//
//  ChangePasswordView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.04.2022.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPasswordText = ""
    @State private var newPasswordText = ""
    @State private var newPasswordAgainText = ""
    @State private var isChangeSuccessful = false
    @State private var changeSuccessTitle = "Пароль изменен"
    @FocusState private var focus: FocusableField?

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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                focus = .currentPassword
            }
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
            SecureField("Текущий пароль", text: $currentPasswordText)
                .focused($focus, equals: .currentPassword)
        }
    }

    func newPasswordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Новый пароль", text: $newPasswordText)
                .focused($focus, equals: .newPassword)
        }
    }

    func newPasswordAgainField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Новый пароль ещё раз", text: $newPasswordAgainText)
                .focused($focus, equals: .newPasswordAgain)
        }
    }

    func changePasswordButton() -> some View {
        Button {
#warning("Выполнить смену пароля")
            print("--- Изменяем пароль")
            focus = nil
            isChangeSuccessful.toggle()
        } label: {
            ButtonInFormLabel(title: "Сохранить изменения")
        }
        .alert(changeSuccessTitle, isPresented: $isChangeSuccessful) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Закрыть")
            }
        }
        .disabled(isChangeButtonDisabled)
    }

    var isChangeButtonDisabled: Bool {
#warning("Вынести проверку из View")
        let isCurrentPasswordTooShort = currentPasswordText.count < 6
        let isNewPasswordEmpty = newPasswordText.isEmpty || newPasswordAgainText.isEmpty
        let isNewPasswordTooShort = newPasswordText.count < 6 || newPasswordAgainText.count < 6
        let areNewPasswordsNotEqual = newPasswordText != newPasswordAgainText
        return isCurrentPasswordTooShort
        || isNewPasswordEmpty
        || isNewPasswordTooShort
        || areNewPasswordsNotEqual
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
    }
}

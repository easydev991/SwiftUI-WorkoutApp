//
//  LoginView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var loginEmailText = ""
    @State private var passwordText = ""
    @State private var isForgotPasswordAlertShown = false
    @State private var forgotPasswordAlertTitle = "Для восстановления пароля введите логин или email"
    @FocusState private var focus: FocusableField?

    var body: some View {
        Form {
            Section {
                loginField()
                passwordField()
            }
            Section {
                loginButton()
                forgotPasswordButton()
            }
        }
        .navigationTitle("Вход по email")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension LoginView {
    enum FocusableField: Hashable {
        case username
        case password
    }

    func loginField() -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Логин или email", text: $loginEmailText)
                .focused($focus, equals: .username)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focus = .username
            }
        }
    }

    func passwordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Пароль", text: $passwordText)
                .focused($focus, equals: .password)
        }
    }

    func loginButton() -> some View {
        Button {
#warning("Выполнить авторизацию")
            print("--- Выполняем вход")
            appState.isUserAuthorized = true
            appState.showWelcome = false
            focus = nil
        } label: {
            ButtonInFormLabel(title: "Войти")
        }
        .disabled(loginEmailText.isEmpty || passwordText.count < 6)
    }

    func forgotPasswordButton() -> some View {
        Button {
#warning("Запросить восстановление пароля или показать алерт")
            print("--- Запрашиваем восстановление пароля")
            focus = .username
            isForgotPasswordAlertShown.toggle()
        } label: {
            HStack {
                Spacer()
                Text("Забыли пароль?")
                    .tint(.blue)
                Spacer()
            }
        }
        .alert(forgotPasswordAlertTitle, isPresented: $isForgotPasswordAlertShown) {
            Text("Ok")
        }
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}

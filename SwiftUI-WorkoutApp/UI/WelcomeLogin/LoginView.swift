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
    }
}

private extension LoginView {
    func loginField() -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Логин или email", text: $loginEmailText)
        }
    }

    func passwordField() -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Пароль", text: $passwordText)
        }
    }

    func loginButton() -> some View {
        Button {
            #warning("Выполнить авторизацию")
            print("--- Выполняем вход")
            appState.isUserAuthorized = true
            appState.showWelcome = false
        } label: {
            HStack {
                Spacer()
                Text("Войти")
                    .font(.headline)
                Spacer()
            }
        }
        .disabled(loginEmailText.isEmpty || passwordText.count < 6)
    }

    func forgotPasswordButton() -> some View {
        Button {
            #warning("Запросить восстановление пароля или показать алерт")
            print("--- Запрашиваем восстановление пароля")
        } label: {
            HStack {
                Spacer()
                Text("Забыли пароль?")
                    .tint(.blue)
                Spacer()
            }
        }
        .disabled(loginEmailText.isEmpty)
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}

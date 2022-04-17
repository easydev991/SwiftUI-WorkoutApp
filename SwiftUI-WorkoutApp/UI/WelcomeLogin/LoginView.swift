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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                focus = .username
            }
        }
        .navigationTitle("Вход по email")
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
            focus = .username
        } label: {
            HStack {
                Spacer()
                Text("Забыли пароль?")
                    .tint(.blue)
                Spacer()
            }
        }
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}

//
//  LoginView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
// https://cocoacasts.com/networking-essentials-how-to-implement-basic-authentication-in-swift

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
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
            TextField("Логин или email", text: $viewModel.loginEmailText)
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
            SecureField("Пароль", text: $viewModel.passwordText)
                .focused($focus, equals: .password)
        }
    }

    func loginButton() -> some View {
        Button {
            viewModel.loginButtonTapped()
            focus = nil
        } label: {
            ButtonInFormLabel(title: "Войти")
        }
        .disabled(!viewModel.canLogIn)
    }

    func forgotPasswordButton() -> some View {
        Button {
            viewModel.forgotPasswordTapped()
            focus = viewModel.canRestorePassword ? nil : .username
        } label: {
            HStack {
                Spacer()
                Text("Забыли пароль?")
                    .tint(.blue)
                Spacer()
            }
        }
        .alert(viewModel.forgotPasswordAlertTitle, isPresented: $viewModel.showForgotPasswordAlert) {
            Text("Ok")
        }
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

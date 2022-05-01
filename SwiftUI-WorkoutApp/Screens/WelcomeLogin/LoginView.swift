//
//  LoginView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var viewModel = LoginViewModel()
    // Вызывает утечку памяти, если разместить внутри viewModel
    @State private var showForgotPasswordAlert = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @FocusState private var focus: FocusableField?

    var body: some View {
        ZStack {
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
            ProgressView()
                .opacity(viewModel.isSigningIn ? 1 : .zero)
        }
        .disabled(viewModel.isSigningIn)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button {
                viewModel.errorAlertClosed()
            } label: {
                Text("Ок")
            }
        }
        .onChange(of: viewModel.showForgotPasswordAlert) { showAlert in
            showForgotPasswordAlert = showAlert
        }
        .onChange(of: viewModel.errorResponse) { message in
            showErrorAlert = !message.isEmpty
            errorTitle = message
        }
        .navigationTitle("Вход по email")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension LoginView {
    enum FocusableField: Hashable {
        case username, password
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
//            viewModel.loginButtonTapped(with: userDefaults)
            Task {
                await viewModel.loginAsync(with: userDefaults)
            }
            focus = nil
        } label: {
            ButtonInFormLabel(title: "Войти")
        }
        .disabled(!viewModel.canLogIn)
    }

    func forgotPasswordButton() -> some View {
        Button {
            showForgotPasswordAlert = viewModel.loginEmailText.isEmpty
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
        .alert(Constants.AlertTitle.forgotPassword, isPresented: $showForgotPasswordAlert) {
            Text("Ok")
        }
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserDefaultsService())
    }
}

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
                loginPasswordSection
                buttonsSection
            }
            progressView
        }
        .disabled(viewModel.isSigningIn)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: viewModel.errorAlertClosed) {
                TextOk()
            }
        }
        .onChange(of: viewModel.showForgotPasswordAlert) { showForgotPasswordAlert = $0 }
        .onChange(of: viewModel.errorResponse, perform: setupErrorAlert)
        .navigationTitle("Вход по email")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension LoginView {
    enum FocusableField: Hashable {
        case username, password
    }

    var loginPasswordSection: some View {
        Section {
            loginField
            passwordField
        }
    }

    var loginField: some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.secondary)
            TextField("Логин или email", text: $viewModel.login)
                .focused($focus, equals: .username)
        }
        .onAppear(perform: showKeyboard)
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            focus = .username
        }
    }

    var passwordField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            SecureField("Пароль", text: $viewModel.password)
                .focused($focus, equals: .password)
        }
    }

    var buttonsSection: some View {
        Section {
            loginButton
            forgotPasswordButton
        }
    }

    var loginButton: some View {
        Button(action: loginAction) {
            ButtonInFormLabel(title: "Войти")
        }
        .disabled(!viewModel.canLogIn)
    }

    func loginAction() {
        focus = nil
        Task {
            await viewModel.loginAction(with: userDefaults)
        }
    }

    var forgotPasswordButton: some View {
        Button(action: forgotPasswordAction) { forgotPasswordLabel }
            .alert(Constants.AlertTitle.forgotPassword, isPresented: $showForgotPasswordAlert) {
                Button(action: viewModel.warningAlertClosed) { TextOk() }
            }
    }

    func forgotPasswordAction() {
        viewModel.forgotPasswordTapped()
        focus = viewModel.canRestorePassword ? nil : .username
    }

    var forgotPasswordLabel: some View {
        HStack {
            Spacer()
            Text("Забыли пароль?")
                .tint(.blue)
            Spacer()
        }
    }

    var progressView: some View {
        ProgressView()
            .opacity(viewModel.isSigningIn ? 1 : .zero)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserDefaultsService())
    }
}

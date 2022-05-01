//
//  LoginViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    @Published var loginEmailText = ""
    @Published var passwordText = ""
    @Published var hasError = false
    @Published var isSigningIn = false
    @Published var showForgotPasswordAlert = false
    @Published var errorResponse = ""

    var canLogIn: Bool {
        !loginEmailText.isEmpty && passwordText.count >= 6
    }
    var canRestorePassword: Bool {
        !loginEmailText.isEmpty
    }

    init() {
        print("--- inited LoginViewModel")
    }

    deinit {
        print("--- deinited LoginViewModel")
    }

    func errorAlertClosed() {
        errorResponse = ""
    }

    func loginAsync(with defaults: UserDefaultsService) async {
        if !canLogIn {
            return
        }
        await MainActor.run {
            isSigningIn = true
        }
        let loader = LoginService(
            defaults: defaults,
            login: loginEmailText,
            password: passwordText
        )
        do {
            try await loader.loginRequest()
        } catch {
            await MainActor.run {
                errorResponse = error.localizedDescription
                isSigningIn = false
            }
        }
    }

    func forgotPasswordTapped() {
        if canRestorePassword {
#warning("TODO: интеграция с сервером")
        } else {
            showForgotPasswordAlert = true
        }
    }
}

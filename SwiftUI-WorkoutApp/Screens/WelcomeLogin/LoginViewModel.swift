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
    @Published var forgotPasswordAlertTitle = "Для восстановления пароля введите логин или email"
    var canLogIn: Bool {
        !loginEmailText.isEmpty && passwordText.count >= 6
    }
    var canRestorePassword: Bool {
        !loginEmailText.isEmpty
    }

    func loginButtonTapped(with userDefaults: UserDefaultsService) {
#warning("TODO: интеграция с сервером")
        userDefaults.isUserAuthorized = true
        userDefaults.showWelcome = false
    }

    func forgotPasswordTapped() {
        if canRestorePassword {
#warning("TODO: интеграция с сервером")
        } else {
            showForgotPasswordAlert = true
        }
    }
}

//
//  LoginViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    @Published var login = ""
    @Published var password = ""
    @Published var isSigningIn = false
    @Published var showForgotPasswordAlert = false
    @Published var errorResponse = ""

    var canLogIn: Bool {
        !login.isEmpty && password.count >= 6
    }
    var canRestorePassword: Bool {
        !login.isEmpty
    }

    func errorAlertClosed() {
        errorResponse = ""
    }

    func warningAlertClosed() {
        showForgotPasswordAlert = false
    }

    func loginAction(with userDefaults: UserDefaultsService) async {
        if !canLogIn { return }
        await MainActor.run { isSigningIn = true }
        do {
            try await APIService(with: userDefaults).logInWith(login, password)
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

#warning("TODO: убрать принты после окончания работ")
    init() {
        print("--- inited LoginViewModel")
    }

    deinit {
        print("--- deinited LoginViewModel")
    }
}

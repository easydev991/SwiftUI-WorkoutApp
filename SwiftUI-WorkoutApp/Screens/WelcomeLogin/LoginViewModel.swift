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
    @Published var isLoading = false
    @Published var showForgotPasswordAlert = false
    @Published var showResetSuccessfulAlert = false
    @Published var errorResponse = ""

    var canLogIn: Bool {
        !login.isEmpty && password.count >= Constants.minPasswordSize
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

    func resetSuccessfulAlertClosed() {
        showResetSuccessfulAlert = false
    }

    func loginAction(with userDefaults: UserDefaultsService) async {
        if !canLogIn { return }
        await MainActor.run { isLoading = true }
        do {
            try await APIService(with: userDefaults).logInWith(login, password)
        } catch {
            await MainActor.run {
                errorResponse = error.localizedDescription
                isLoading = false
            }
        }
    }

    func forgotPasswordTapped() async {
        if canRestorePassword {
            await MainActor.run { isLoading = true }
            do {
                let isSuccess = try await APIService().resetPassword(for: login)
                await MainActor.run {
                    isLoading = false
                    if isSuccess {
                        showResetSuccessfulAlert = true
                    } else {
                        errorResponse = Constants.Alert.resetPasswordError
                    }
                }
            } catch {
                await MainActor.run {
                    errorResponse = error.localizedDescription
                    isLoading = false
                }
            }
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

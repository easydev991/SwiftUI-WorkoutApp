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
    @Published private(set) var isLoading = false
    @Published private(set) var showForgotPasswordAlert = false
    @Published private(set) var showResetSuccessfulAlert = false
    @Published private(set) var errorMessage = ""

    var canLogIn: Bool {
        !login.isEmpty && password.count >= Constants.minPasswordSize
    }

    var canRestorePassword: Bool { !login.isEmpty }

    func clearErrorMessage() { errorMessage = "" }

    func warningAlertClosed() {
        showForgotPasswordAlert.toggle()
    }

    func resetSuccessfulAlertClosed() {
        showResetSuccessfulAlert.toggle()
    }

    @MainActor
    func loginAction(with userDefaults: UserDefaultsService) async {
        if !canLogIn { return }
        isLoading.toggle()
        do {
            try await APIService(with: userDefaults).logInWith(login, password)
        } catch {
            errorMessage = error.localizedDescription
            isLoading.toggle()
        }
    }

    @MainActor
    func forgotPasswordTapped() async {
        if canRestorePassword {
            isLoading.toggle()
            do {
                let isSuccess = try await APIService().resetPassword(for: login)
                if isSuccess {
                    showResetSuccessfulAlert.toggle()
                } else {
                    errorMessage = Constants.Alert.resetPasswordError
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading.toggle()
        } else {
            showForgotPasswordAlert.toggle()
        }
    }
}

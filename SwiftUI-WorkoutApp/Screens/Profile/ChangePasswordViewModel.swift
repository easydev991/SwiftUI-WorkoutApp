//
//  ChangePasswordViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class ChangePasswordViewModel: ObservableObject {
    @Published var currentPasswordText = ""
    @Published var newPasswordText = ""
    @Published var newPasswordAgainText = ""
    @Published var isChangeSuccessful = false
    @Published var isLoading = false
    @Published var errorResponse = ""
    var isChangeButtonDisabled: Bool {
        let isCurrentPasswordTooShort = currentPasswordText.count < Constants.minPasswordSize
        let isNewPasswordEmpty = newPasswordText.isEmpty || newPasswordAgainText.isEmpty
        let isNewPasswordTooShort = newPasswordText.count < Constants.minPasswordSize
        || newPasswordAgainText.count < Constants.minPasswordSize
        let areNewPasswordsNotEqual = newPasswordText != newPasswordAgainText
        return isCurrentPasswordTooShort
        || isNewPasswordEmpty
        || isNewPasswordTooShort
        || areNewPasswordsNotEqual
    }

    func changePasswordAction() async {
        await MainActor.run { isLoading = true }
        let isSuccess = try? await APIService().changePassword(
            current: currentPasswordText,
            new: newPasswordText
        )
        await MainActor.run {
            isLoading = false
            if isSuccess.isTrue {
                isChangeSuccessful = true
            } else {
                errorResponse = Constants.Alert.changePasswordError
            }
        }
    }

    func errorAlertClosed() {
        errorResponse = ""
    }

    init() {
        print("--- inited ChangePasswordViewModel")
    }

    deinit {
        print("--- deinited ChangePasswordViewModel")
    }
}

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
    @Published private(set) var isChangeSuccessful = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
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

    @MainActor
    func changePasswordAction() async {
        isLoading.toggle()
        let isSuccess = try? await APIService().changePassword(
            current: currentPasswordText,
            new: newPasswordText
        )
        isLoading.toggle()
        if isSuccess.isTrue {
            isChangeSuccessful.toggle()
        } else {
            errorMessage = Constants.Alert.changePasswordError
        }
    }

    func errorAlertClosed() {
        errorMessage = ""
    }

    init() {
        print("--- inited ChangePasswordViewModel")
    }

    deinit {
        print("--- deinited ChangePasswordViewModel")
    }
}

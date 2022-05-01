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
    var isChangeButtonDisabled: Bool {
        let isCurrentPasswordTooShort = currentPasswordText.count < 6
        let isNewPasswordEmpty = newPasswordText.isEmpty || newPasswordAgainText.isEmpty
        let isNewPasswordTooShort = newPasswordText.count < 6 || newPasswordAgainText.count < 6
        let areNewPasswordsNotEqual = newPasswordText != newPasswordAgainText
        return isCurrentPasswordTooShort
        || isNewPasswordEmpty
        || isNewPasswordTooShort
        || areNewPasswordsNotEqual
    }

    func changePasswordAction() {
#warning("TODO: интеграция с сервером")
        // убрать хардкод после интеграции
        isChangeSuccessful = true
    }
}

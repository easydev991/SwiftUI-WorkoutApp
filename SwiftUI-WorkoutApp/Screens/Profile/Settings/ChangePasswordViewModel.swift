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
        do {
            if try await APIService().changePassword(current: currentPasswordText, new: newPasswordText) {
                isChangeSuccessful.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func errorAlertClosed() { errorMessage = "" }
}

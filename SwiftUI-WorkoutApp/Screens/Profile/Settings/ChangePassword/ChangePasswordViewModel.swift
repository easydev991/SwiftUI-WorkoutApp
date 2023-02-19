import Foundation
import SWModels

@MainActor
final class ChangePasswordViewModel: ObservableObject {
    @Published var currentPasswordText = ""
    @Published var newPasswordText = ""
    @Published var newPasswordTextAgain = ""
    @Published private(set) var isChangeSuccessful = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func changePasswordAction(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isChangeSuccessful = try await APIService(with: defaults).changePassword(
                current: currentPasswordText, new: newPasswordText
            )
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func errorAlertClosed() { errorMessage = "" }
}

extension ChangePasswordViewModel {
    var isChangeButtonDisabled: Bool {
        isLoading
            || currentPasswordText.count < Constants.minPasswordSize
            || newPasswordText.count < Constants.minPasswordSize
            || newPasswordText != newPasswordTextAgain
    }
}

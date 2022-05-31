import Foundation

@MainActor
final class ChangePasswordViewModel: ObservableObject {
    @Published var currentPasswordText = ""
    @Published var newPasswordText = ""
    @Published var newPasswordAgainText = ""
    @Published private(set) var isChangeSuccessful = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    var isChangeButtonDisabled: Bool {
        currentPasswordText.count < Constants.minPasswordSize
        || newPasswordText.count < Constants.minPasswordSize
        || newPasswordText != newPasswordAgainText
    }

    func changePasswordAction(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isChangeSuccessful = try await APIService(with: defaults).changePassword(
                current: currentPasswordText, new: newPasswordText
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func errorAlertClosed() { errorMessage = "" }
}

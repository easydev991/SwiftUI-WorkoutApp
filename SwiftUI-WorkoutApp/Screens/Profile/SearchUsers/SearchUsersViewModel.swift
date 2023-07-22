import Foundation
import SWModels

@MainActor
final class SearchUsersViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func searchFor(user: String, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let result = try await APIService(with: defaults)
                .findUsers(with: user.withoutSpaces)
            users = result.map(UserModel.init)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

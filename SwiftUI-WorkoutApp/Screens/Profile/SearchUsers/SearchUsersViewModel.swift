import Foundation

@MainActor
final class SearchUsersViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isMessageSent = false

    func searchFor(user: String, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let name = user.replacingOccurrences(of: " ", with: "")
            let result = try await APIService(with: defaults).findUsers(with: name)
            users = result.map(UserModel.init)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func send(_ message: String, to userID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).sendMessage(message, to: userID) {
                isMessageSent.toggle()
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

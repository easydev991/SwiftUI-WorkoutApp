import Foundation
import SWModels
import SWNetworkClient

#warning("Лишняя вьюмодель")
@MainActor
final class MessagingViewModel: ObservableObject {
    @Published var messageText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isMessageSent = false
    @Published private(set) var errorMessage = ""
    var canSendMessage: Bool { !messageText.isEmpty && !isLoading }

    func sendMessage(to userID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await SWClient(with: defaults).sendMessage(messageText, to: userID) {
                isMessageSent.toggle()
            }
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

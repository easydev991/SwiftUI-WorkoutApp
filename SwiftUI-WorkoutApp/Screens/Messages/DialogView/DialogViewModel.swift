import Foundation

@MainActor
final class DialogViewModel: ObservableObject {
    @Published var newMessage = ""
    @Published var list = [MessageResponse]()
    @Published private(set) var markedAsRead = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func makeItems(for dialogID: Int, refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getMessages(for: dialogID).reversed()
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func markAsRead(from userID: Int, with defaults: DefaultsProtocol) async {
        do {
            if try await APIService(with: defaults).markAsRead(from: userID) {
                markedAsRead = true
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
    }

    func sendMessage(in dialog: Int, to userID: Int, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).sendMessage(newMessage, to: userID) {
                newMessage = ""
                await makeItems(for: dialog, refresh: true, with: defaults)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

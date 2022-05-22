import Foundation

final class DialogViewModel: ObservableObject {
    @Published var newMessage = ""
    @Published var list = [MessageResponse]()
    @Published private(set) var markedAsRead = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeItems(for dialogID: Int, with defaults: DefaultsService, refresh: Bool = false) async {
        if isLoading && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getMessages(for: dialogID).reversed()
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func markAsRead(from userID: Int, with defaults: DefaultsService) async {
        do {
            if try await APIService(with: defaults).markAsRead(from: userID) {
                markedAsRead = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func sendMessage(in dialog: Int, to userID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).sendMessage(newMessage, to: userID) {
                newMessage = ""
                await makeItems(for: dialog, with: defaults, refresh: true)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

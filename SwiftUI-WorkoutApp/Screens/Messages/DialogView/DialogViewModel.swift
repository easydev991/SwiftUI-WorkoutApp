import Foundation

final class DialogViewModel: ObservableObject {
    @Published var newMessage = ""
    @Published var list = [MessageResponse]()
    @Published private(set) var markedAsRead = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeItems(for dialogID: Int, refresh: Bool = false) async {
        if isLoading && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService().getMessages(for: dialogID).reversed()
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func markAsRead(from userID: Int) async {
        do {
            if try await APIService().markAsRead(from: userID) {
                markedAsRead = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func sendMessage(in dialog: Int, to userID: Int) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService().sendMessage(newMessage, to: userID) {
                newMessage = ""
                await makeItems(for: dialog, refresh: true)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

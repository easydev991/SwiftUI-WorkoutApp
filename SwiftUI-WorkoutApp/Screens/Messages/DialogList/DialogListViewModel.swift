import Foundation
import SWModels
import SWNetworkClient

#warning("Лишняя вьюмодель")
@MainActor
final class DialogListViewModel: ObservableObject {
    @Published var list = [DialogResponse]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func makeItems(with defaults: DefaultsService, refresh: Bool) async {
        if isLoading || (!list.isEmpty && !refresh) { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await SWClient(with: defaults).getDialogs()
            let unreadMessagesCount = list.map(\.unreadMessagesCount).reduce(0, +)
            defaults.saveUnreadMessagesCount(unreadMessagesCount)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func deleteDialog(at index: Int?, with defaults: DefaultsProtocol) async {
        guard let index, !isLoading else { return }
        isLoading.toggle()
        do {
            let dialogID = list[index].id
            if try await SWClient(with: defaults).deleteDialog(dialogID) {
                list.remove(at: index)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func markAsRead(_ dialog: DialogResponse, with defaults: DefaultsProtocol) {
        list = list.map { item in
            if item.id == dialog.id {
                var updatedDialog = dialog
                updatedDialog.unreadMessagesCount = 0
                return updatedDialog
            } else {
                return item
            }
        }
        guard dialog.unreadMessagesCount > 0,
              defaults.unreadMessagesCount >= dialog.unreadMessagesCount
        else { return }
        let newValue = defaults.unreadMessagesCount - dialog.unreadMessagesCount
        defaults.saveUnreadMessagesCount(newValue)
    }

    func clearErrorMessage() { errorMessage = "" }
}

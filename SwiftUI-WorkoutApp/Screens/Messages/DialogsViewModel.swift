import Foundation
import SWModels
import SWNetworkClient
import SWUtils

final class DialogsViewModel: ObservableObject {
    @Published private(set) var dialogs = [DialogResponse]()
    @Published private(set) var isLoading = false
    var hasDialogs: Bool { !dialogs.isEmpty }
    var showEmptyView: Bool { !hasDialogs && !isLoading }

    @MainActor
    func askForDialogs(
        refresh: Bool = false,
        defaults: DefaultsService
    ) async throws {
        guard defaults.isAuthorized else { return }
        if isLoading || (!dialogs.isEmpty && !refresh) { return }
        if !refresh || dialogs.isEmpty { isLoading = true }
        dialogs = try await SWClient(with: defaults).getDialogs()
        let unreadMessagesCount = dialogs.map(\.unreadMessagesCount).reduce(0, +)
        defaults.saveUnreadMessagesCount(unreadMessagesCount)
        isLoading = false
    }

    @MainActor
    func deleteDialog(at index: Int?, defaults: DefaultsService) async throws {
        guard let index, !isLoading else { return }
        isLoading = true
        let dialogID = dialogs[index].id
        if try await SWClient(with: defaults).deleteDialog(dialogID) {
            dialogs.remove(at: index)
        }
        isLoading = false
    }

    @MainActor
    func markAsRead(_ dialog: DialogResponse, defaults: DefaultsService) {
        dialogs = dialogs.map { item in
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

    @MainActor
    func clearDialogsOnLogout(isAuthorized: Bool) {
        guard !isAuthorized else { return }
        dialogs.removeAll()
    }
}

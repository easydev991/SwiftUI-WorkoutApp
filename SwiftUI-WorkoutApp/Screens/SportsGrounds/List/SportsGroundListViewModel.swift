import Foundation

final class SportsGroundListViewModel: ObservableObject {
    @Published private(set) var list = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeSportsGroundsFor(_ mode: SportsGroundsListView.Mode, refresh: Bool) async {
        switch mode {
        case let .usedBy(userID), let .event(userID):
            if isLoading || (!list.isEmpty && !refresh) { return }
#warning("TODO: обновлять список для mainUser, если needUpdateUser == true")
            if !refresh { isLoading.toggle() }
            do {
                list = try await APIService().getSportsGroundsForUser(userID)
            } catch {
                errorMessage = error.localizedDescription
            }
            if !refresh { isLoading.toggle() }
        case let .added(list):
            self.list = list
        }
    }

    func deleteSportsGround(id: Int) {
#warning("TODO: обновлять список добавленных пользователем площадок в БД")
        list.removeAll(where: { $0.id == id })
    }

    func clearErrorMessage() { errorMessage = "" }
}

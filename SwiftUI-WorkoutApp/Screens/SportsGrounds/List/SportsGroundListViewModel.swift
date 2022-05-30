import Foundation

final class SportsGroundListViewModel: ObservableObject {
    @Published private(set) var list = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeSportsGroundsFor(_ mode: SportsGroundsListView.Mode, refresh: Bool) async {
        if isLoading { return }
        switch mode {
        case let .usedBy(userID), let .event(userID):
            let defaults = DefaultsService()
            let isMainUser = userID == defaults.mainUserID
            let needUpdate = list.isEmpty || refresh
            if isMainUser {
#warning("TODO: вместо needUpdateUser проверять список площадок пользователя в БД, чтобы не делать лишние запросы")
                if !needUpdate && !defaults.needUpdateUser { return }
                isLoading.toggle()
                await makeList(for: userID)
            } else {
                if !needUpdate { return }
                isLoading.toggle()
                await makeList(for: userID)
            }
            isLoading.toggle()
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

private extension SportsGroundListViewModel {
    func makeList(for userID: Int) async {
        do {
            if userID == DefaultsService().mainUserID {
#warning("TODO: интеграция с БД")
                await DefaultsService().setUserNeedUpdate(false)
            }
            list = try await APIService().getSportsGroundsForUser(userID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

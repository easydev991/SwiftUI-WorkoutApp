import Foundation

@MainActor
final class SportsGroundListViewModel: ObservableObject {
    @Published private(set) var list = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func makeSportsGroundsFor(_ mode: SportsGroundsListView.Mode, refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        switch mode {
        case let .usedBy(userID), let .event(userID):
            let isMainUser = userID == defaults.mainUserInfo?.userID
            let needUpdate = list.isEmpty || refresh
            if isMainUser {
                if !needUpdate, !defaults.needUpdateUser { return }
                isLoading.toggle()
                await makeList(for: userID, with: defaults)
            } else {
                if !needUpdate { return }
                isLoading.toggle()
                await makeList(for: userID, with: defaults)
            }
            isLoading.toggle()
        case let .added(list):
            self.list = list
        }
    }

    func deleteSportsGround(id: Int) {
        list.removeAll(where: { $0.id == id })
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension SportsGroundListViewModel {
    func makeList(for userID: Int, with defaults: DefaultsProtocol) async {
        do {
            if userID == defaults.mainUserInfo?.userID {
                defaults.setUserNeedUpdate(false)
            }
            list = try await APIService(with: defaults).getSportsGroundsForUser(userID)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
    }
}

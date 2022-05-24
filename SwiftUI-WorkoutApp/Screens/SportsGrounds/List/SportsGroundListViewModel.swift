import Foundation

final class SportsGroundListViewModel: ObservableObject {
    @Published private(set) var list = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeSportsGroundsFor(_ mode: SportsGroundsListView.Mode, refresh: Bool, with defaults: DefaultsService) async {
        switch mode {
        case let .usedBy(userID), let .event(userID):
            if isLoading || (!list.isEmpty && !refresh) { return }
            if !refresh { isLoading.toggle() }
            do {
                list = try await APIService(with: defaults).getSportsGroundsForUser(userID)
            } catch {
                errorMessage = error.localizedDescription
            }
            if !refresh { isLoading.toggle() }
        case let .added(list):
            self.list = list
        }
    }

    func clearErrorMessage() { errorMessage = "" }
}

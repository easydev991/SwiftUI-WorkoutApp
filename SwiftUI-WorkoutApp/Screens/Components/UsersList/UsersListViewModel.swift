import Foundation

@MainActor
final class UsersListViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var friendRequests = [UserModel]()
    @Published private(set) var errorMessage = ""
    @Published private(set) var isLoading = false

    func makeInfo(for mode: UsersListView.Mode, refresh: Bool, with defaults: DefaultsService) async {
        if (!users.isEmpty || isLoading) && !refresh { return }
        switch mode {
        case let .friends(userID):
            await makeFriendsList(for: userID, refresh: refresh, with: defaults)
        case let .participants(list):
            users = list.map(UserModel.init)
        }
    }

    func respondToFriendRequest(from userID: Int, accept: Bool, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).respondToFriendRequest(from: userID, accept: accept) {
                friendRequests = defaults.friendRequestsList.map(UserModel.init)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension UsersListViewModel {
    func makeFriendsList(for id: Int, refresh: Bool, with defaults: DefaultsService) async {
        let isMainUser = id == defaults.mainUserID
        if !refresh { isLoading.toggle() }
        do {
            if isMainUser {
                await checkFriendRequests(refresh: refresh, with: defaults)
            }
            let friends = try await APIService(with: defaults).getFriendsForUser(id: id)
            users = friends.map(UserModel.init)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    func checkFriendRequests(refresh: Bool, with defaults: DefaultsService) async {
        if defaults.friendRequestsList.isEmpty || refresh {
            try? await APIService(with: defaults).getFriendRequests()
        }
        friendRequests = defaults.friendRequestsList.map(UserModel.init)
    }
}

import Foundation

@MainActor
final class UsersListViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var friendRequests = [UserModel]()
    @Published private(set) var errorMessage = ""
    @Published private(set) var isLoading = false

    func makeInfo(for mode: UsersListView.Mode, refresh: Bool, with defaults: DefaultsProtocol) async {
        if (!users.isEmpty || isLoading) && !refresh { return }
        switch mode {
        case let .friends(userID), let .friendsForChat(userID):
            await makeFriendsList(for: userID, refresh: refresh, with: defaults)
        case let .eventParticipants(list), let .groundParticipants(list):
            users = list.map(UserModel.init)
        case .blacklist:
            await makeBlacklist(refresh: refresh, with: defaults)
        }
    }

    func respondToFriendRequest(from userID: Int, accept: Bool, with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).respondToFriendRequest(from: userID, accept: accept) {
                friendRequests = defaults.friendRequestsList.map(UserModel.init)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension UsersListViewModel {
    func makeFriendsList(for id: Int, refresh: Bool, with defaults: DefaultsProtocol) async {
        let isMainUser = id == defaults.mainUserInfo?.userID
        if !refresh { isLoading.toggle() }
        do {
            if isMainUser {
                await checkFriendRequests(refresh: refresh, with: defaults)
            }
            let friends = try await APIService(with: defaults).getFriendsForUser(id: id)
            users = friends.map(UserModel.init)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func checkFriendRequests(refresh: Bool, with defaults: DefaultsProtocol) async {
        if defaults.friendRequestsList.isEmpty || refresh {
            try? await APIService(with: defaults).getFriendRequests()
        }
        friendRequests = defaults.friendRequestsList.map(UserModel.init)
    }

    func makeBlacklist(refresh: Bool, with defaults: DefaultsProtocol) async {
        if !refresh { isLoading.toggle() }
        do {
            let blacklist = try await APIService(with: defaults).getBlacklist()
            users = blacklist.map(UserModel.init)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }
}

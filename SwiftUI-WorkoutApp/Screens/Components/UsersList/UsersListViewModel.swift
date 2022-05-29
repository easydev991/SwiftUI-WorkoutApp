import Foundation

final class UsersListViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var friendRequests = [UserModel]()
    @Published private(set) var errorMessage = ""
    @Published private(set) var isLoading = false

    @MainActor
    func makeInfo(for mode: UsersListView.Mode, refresh: Bool = false) async {
        if (!users.isEmpty || isLoading) && !refresh { return }
        switch mode {
        case let .friends(userID):
            await makeFriendsList(for: userID, refresh: refresh)
        case let .participants(list):
            users = list.map(UserModel.init)
        }
    }

    @MainActor
    func respondToFriendRequest(from userID: Int, accept: Bool) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService().respondToFriendRequest(from: userID, accept: accept) {
                friendRequests = DefaultsService().friendRequestsList.map(UserModel.init)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension UsersListViewModel {
    @MainActor
    func makeFriendsList(for id: Int, refresh: Bool) async {
        let isMainUser = id == DefaultsService().mainUserID
        let service = APIService()
        if !refresh { isLoading.toggle() }
        do {
            if isMainUser {
                await checkFriendRequests(refresh: refresh)
            }
            let friends = try await service.getFriendsForUser(id: id)
            users = friends.map(UserModel.init)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func checkFriendRequests(refresh: Bool) async {
        if DefaultsService().friendRequestsList.isEmpty || refresh {
            try? await APIService().getFriendRequests()
        }
        friendRequests = DefaultsService().friendRequestsList.map(UserModel.init)
    }
}

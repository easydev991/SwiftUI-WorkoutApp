import Foundation

final class UserDetailsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var requestedFriendship = false
    @Published private(set) var friendActionOption = Constants.FriendAction.sendFriendRequest
    @Published private(set) var user: UserModel
    @Published private(set) var errorMessage = ""
    @Published private(set) var isMessageSent = false

    init(with userInfo: UserResponse?) {
        user = .init(userInfo)
    }

    init(from model: UserModel) {
        user = model
    }

    init(from dialog: DialogResponse) {
        user = .init(from: dialog)
    }

    @MainActor
    func makeUserInfo(refresh: Bool) async {
        let defaults = DefaultsService()
        let isMainUser = user.id == defaults.mainUserID
        if !refresh { isLoading.toggle() }
        if isMainUser {
            if !refresh && !defaults.needUpdateUser,
               let mainUserInfo = defaults.mainUserInfo {
                user = .init(mainUserInfo)
            } else {
                await makeUserInfo(for: user.id)
            }
        } else {
            if user.isFull && !refresh {
                isLoading.toggle()
                return
            }
            await makeUserInfo(for: user.id)
            friendActionOption = defaults.friendsIdsList.contains(user.id)
            ? .removeFriend
            : .sendFriendRequest
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func checkFriendRequests() async {
        try? await APIService().getFriendRequests()
    }

    @MainActor
    func friendAction() async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService().friendAction(userID: user.id, option: friendActionOption) {
                switch friendActionOption {
                case .sendFriendRequest:
                    requestedFriendship.toggle()
                case .removeFriend:
                    friendActionOption = .sendFriendRequest
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func send(_ message: String) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService().sendMessage(message, to: user.id) {
                isMessageSent.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension UserDetailsViewModel {
    func makeUserInfo(for userID: Int) async {
        do {
            let info = try await APIService().getUserByID(user.id)
            user = .init(info)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

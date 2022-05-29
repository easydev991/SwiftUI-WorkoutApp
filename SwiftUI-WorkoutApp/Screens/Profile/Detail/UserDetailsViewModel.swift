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
    func makeUserInfo(with defaults: DefaultsService, refresh: Bool) async {
        let isMainUser = user.id == defaults.mainUserID
        if user.isFull && !refresh { return }
        if !refresh { isLoading.toggle() }
        if isMainUser, !refresh,
           let mainUserInfo = defaults.mainUserInfo {
            user = .init(mainUserInfo)
        } else {
            do {
                let info = try await APIService().getUserByID(user.id)
                if !isMainUser {
                    friendActionOption = defaults.friendsIdsList.contains(user.id)
                    ? .removeFriend
                    : .sendFriendRequest
                }
                user = .init(info)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func checkFriendRequests(with defaults: DefaultsService) async {
        try? await APIService(with: defaults).getFriendRequests()
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
    func send(_ message: String, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).sendMessage(message, to: user.id) {
                isMessageSent.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

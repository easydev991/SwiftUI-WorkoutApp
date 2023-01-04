import Foundation

@MainActor
final class UserDetailsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var requestedFriendship = false
    @Published private(set) var friendActionOption = FriendAction.sendFriendRequest
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

    func makeUserInfo(refresh: Bool, with defaults: DefaultsService) async {
        let isMainUser = user.id == defaults.mainUserID
        if !refresh { isLoading.toggle() }
        if isMainUser {
            if !refresh && !defaults.needUpdateUser,
               let mainUserInfo = defaults.mainUserInfo {
                user = .init(mainUserInfo)
            } else {
                await makeUserInfo(for: user.id, with: defaults)
            }
        } else {
            if user.isFull && !refresh {
                isLoading.toggle()
                return
            }
            await makeUserInfo(for: user.id, with: defaults)
            friendActionOption = defaults.friendsIdsList.contains(user.id)
            ? .removeFriend
            : .sendFriendRequest
        }
        if !refresh { isLoading.toggle() }
    }

    func checkFriendRequests(with defaults: DefaultsService) async {
        try? await APIService(with: defaults).getFriendRequests()
    }

    func friendAction(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).friendAction(userID: user.id, option: friendActionOption) {
                switch friendActionOption {
                case .sendFriendRequest:
                    requestedFriendship.toggle()
                case .removeFriend:
                    friendActionOption = .sendFriendRequest
                }
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func send(_ message: String, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).sendMessage(message, to: user.id) {
                isMessageSent.toggle()
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension UserDetailsViewModel {
    func makeUserInfo(for userID: Int, with defaults: DefaultsService) async {
        do {
            let info = try await APIService(with: defaults).getUserByID(user.id)
            user = .init(info)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
    }
}

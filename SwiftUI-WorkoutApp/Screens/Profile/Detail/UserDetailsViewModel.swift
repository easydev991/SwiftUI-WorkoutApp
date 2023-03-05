import Foundation
import SWModels

@MainActor
final class UserDetailsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var requestedFriendship = false
    @Published private(set) var friendActionOption = FriendAction.sendFriendRequest
    @Published private(set) var blacklistActionOption = BlacklistOption.add
    @Published private(set) var user: UserModel
    @Published private(set) var responseMessage = ""

    init(with userInfo: UserResponse?) {
        self.user = .init(userInfo)
    }

    init(from model: UserModel) {
        self.user = model
    }

    init(from dialog: DialogResponse) {
        self.user = .init(from: dialog)
    }

    func makeUserInfo(refresh: Bool, with defaults: DefaultsProtocol) async {
        let isMainUser = user.id == defaults.mainUserInfo?.userID
        if !refresh { isLoading.toggle() }
        if isMainUser {
            if !refresh, !defaults.needUpdateUser,
               let mainUserInfo = defaults.mainUserInfo {
                user = .init(mainUserInfo)
            } else {
                await makeUserInfo(for: user.id, with: defaults)
            }
            await checkFriendRequests(with: defaults)
            await checkBlacklist(with: defaults)
        } else {
            if user.isFull, !refresh {
                isLoading.toggle()
                return
            }
            await makeUserInfo(for: user.id, with: defaults)
            let isPersonInFriendList = defaults.friendsIdsList.contains(user.id)
            friendActionOption = isPersonInFriendList ? .removeFriend : .sendFriendRequest
            let isPersonBlocked = defaults.blacklistedUsers.compactMap(\.userID).contains(user.id)
            blacklistActionOption = isPersonBlocked ? .remove : .add
        }
        if !refresh { isLoading.toggle() }
    }

    func blacklistUser(with defaults: DefaultsProtocol) async {
        guard user.id != defaults.mainUserInfo?.userID else { return }
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).blacklistAction(
                userID: user.id, option: blacklistActionOption
            ) {
                switch blacklistActionOption {
                case .add:
                    responseMessage = "Пользователь добавлен в черный список"
                    blacklistActionOption = .remove
                case .remove:
                    responseMessage = "Пользователь удален из черного списка"
                    blacklistActionOption = .add
                }
            }
        } catch {
            responseMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func friendAction(with defaults: DefaultsProtocol) async {
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
            responseMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { responseMessage = "" }
}

private extension UserDetailsViewModel {
    func makeUserInfo(for _: Int, with defaults: DefaultsProtocol) async {
        do {
            let info = try await APIService(with: defaults).getUserByID(user.id)
            user = .init(info)
        } catch {
            responseMessage = ErrorFilterService.message(from: error)
        }
    }

    func checkFriendRequests(with defaults: DefaultsProtocol) async {
        try? await APIService(with: defaults).getFriendRequests()
    }

    func checkBlacklist(with defaults: DefaultsProtocol) async {
        try? await APIService(with: defaults).getBlacklist()
    }
}

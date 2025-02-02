import SwiftUI
import SWModels
import SWUtils

@MainActor
final class DefaultsService: ObservableObject, DefaultsProtocol {
    var authToken: String? { try? basicAuthInfo().token }

    @AppStorage(Key.needUpdateUser.rawValue)
    private(set) var needUpdateUser = false

    var isAuthorized: Bool { mainUserInfo != nil }

    @AppStorage(Key.appTheme.rawValue)
    private(set) var appTheme = AppColorTheme.system

    @AppStorage(Key.authData.rawValue)
    private var authData = Data()

    @AppStorage(Key.userInfo.rawValue)
    private var userInfo = Data()

    @AppStorage(Key.friends.rawValue)
    private var friendsIds = Data()

    @AppStorage(Key.friendRequests.rawValue)
    private var friendRequests = Data()

    @AppStorage(Key.blacklist.rawValue)
    private var blacklist = Data()

    var hasParks: Bool { mainUserInfo?.hasUsedParks == true }

    var hasJournals: Bool { mainUserInfo?.hasJournals == true }

    var hasFriends: Bool { !friendsIdsList.isEmpty }

    @AppStorage(Key.unreadMessagesCount.rawValue)
    private(set) var unreadMessagesCount = 0

    @AppStorage(Key.lastCountriesUpdateDate.rawValue)
    private(set) var lastCountriesUpdateDate = Date(timeIntervalSince1970: 1673470800.0)

    var mainUserInfo: UserResponse? {
        try? JSONDecoder().decode(UserResponse.self, from: userInfo)
    }

    var mainUserCountryID: Int {
        mainUserInfo?.countryID ?? 0
    }

    var mainUserCityID: Int {
        mainUserInfo?.cityID ?? 0
    }

    var blacklistedUsers: [UserResponse] {
        if let array = try? JSONDecoder().decode([UserResponse].self, from: blacklist) {
            array
        } else {
            []
        }
    }

    var blacklistedUsersCountString: String {
        String.localizedStringWithFormat(
            "usersCount".localized,
            blacklistedUsers.count
        )
    }

    var friendsIdsList: [Int] {
        if let array = try? JSONDecoder().decode([Int].self, from: friendsIds) {
            array
        } else {
            []
        }
    }

    var friendRequestsList: [UserResponse] {
        if let list = try? JSONDecoder().decode([UserResponse].self, from: friendRequests) {
            list
        } else {
            []
        }
    }

    func setAppTheme(_ theme: AppColorTheme) {
        appTheme = theme
    }

    func saveAuthData(login: String, password: String) throws {
        let model = AuthData(login: login, password: password)
        authData = try JSONEncoder().encode(model)
    }

    func basicAuthInfo() throws -> AuthData {
        try JSONDecoder().decode(AuthData.self, from: authData)
    }

    func setUserNeedUpdate(_ newValue: Bool) {
        needUpdateUser = newValue
    }

    func saveUserInfo(_ info: UserResponse) throws {
        userInfo = try JSONEncoder().encode(info)
        setUserNeedUpdate(false)
    }

    func saveFriendsIds(_ ids: [Int]) throws {
        friendsIds = try JSONEncoder().encode(ids)
    }

    func saveFriendRequests(_ array: [UserResponse]) throws {
        friendRequests = try JSONEncoder().encode(array)
    }

    func saveBlacklist(_ array: [UserResponse]) throws {
        blacklist = try JSONEncoder().encode(array)
    }

    func updateBlacklist(option: BlacklistOption, user: UserResponse) {
        var newList = blacklistedUsers
        switch option {
        case .add:
            newList.append(user)
        case .remove:
            newList.removeAll(where: { $0.id == user.id })
        }
        try? saveBlacklist(newList)
    }

    func saveUnreadMessagesCount(_ count: Int) {
        unreadMessagesCount = count
    }

    func didUpdateCountries() {
        lastCountriesUpdateDate = .now
    }

    /// Обновляет сохраненный список идентификаторов друзей главного пользователя
    ///
    /// Если друга удаляют, то удаляем его `id` из списка сохраненных друзей
    /// - Parameters:
    ///   - friendID: `id` друга
    ///   - action: действие с другом (отправка заявки/удаление)
    func updateFriendIds(friendID: Int, action: FriendAction) {
        var newList = friendsIdsList
        guard case .removeFriend = action else { return }
        newList.removeAll(where: { $0 == friendID })
        try? saveFriendsIds(newList)
    }

    func triggerLogout() {
        authData = .init()
        userInfo = .init()
        try? saveFriendsIds([])
        try? saveFriendRequests([])
        try? saveBlacklist([])
        saveUnreadMessagesCount(0)
        setUserNeedUpdate(true)
    }
}

extension DefaultsService {
    var userFlags: UserFlags {
        .init(
            isAuthorized: isAuthorized,
            needUpdate: needUpdateUser,
            hasParks: hasParks,
            hasFriends: hasFriends,
            hasJournals: hasJournals
        )
    }
}

private extension DefaultsService {
    enum Key: String {
        case appTheme, authData, userInfo, friends, friendRequests, blacklist, needUpdateUser, unreadMessagesCount, lastCountriesUpdateDate
    }
}

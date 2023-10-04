import SwiftUI
import SWModels

@MainActor
final class DefaultsService: ObservableObject, DefaultsProtocol {
    @AppStorage(Key.needUpdateUser.rawValue)
    private(set) var needUpdateUser = false

    @AppStorage(Key.isUserAuthorized.rawValue)
    private(set) var isAuthorized = false

    @AppStorage(Key.appLanguage.rawValue)
    private(set) var appLanguage = AppLanguage(
        rawValue: Locale.current.languageCode ?? "ru"
    ) ?? .rus

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

    @AppStorage(Key.hasSportsGrounds.rawValue)
    private(set) var hasSportsGrounds = false

    @AppStorage(Key.hasJournals.rawValue)
    private(set) var hasJournals = false

    @AppStorage(Key.hasFriends.rawValue)
    private(set) var hasFriends = false

    @AppStorage(Key.unreadMessagesCount.rawValue)
    private(set) var unreadMessagesCount = 0

    var mainUserInfo: UserResponse? {
        try? JSONDecoder().decode(UserResponse.self, from: userInfo)
    }

    var mainUserCountryID: Int {
        (mainUserInfo?.countryID).valueOrZero
    }

    var mainUserCityID: Int {
        (mainUserInfo?.cityID).valueOrZero
    }

    var blacklistedUsers: [UserResponse] {
        if let array = try? JSONDecoder().decode([UserResponse].self, from: blacklist) {
            return array
        } else {
            return []
        }
    }

    var blacklistedUsersCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("usersCount", comment: ""),
            blacklistedUsers.count
        )
    }

    var friendsIdsList: [Int] {
        if let array = try? JSONDecoder().decode([Int].self, from: friendsIds) {
            return array
        } else {
            return []
        }
    }

    var friendRequestsList: [UserResponse] {
        if let list = try? JSONDecoder().decode([UserResponse].self, from: friendRequests) {
            return list
        } else {
            return []
        }
    }

    func setAppLanguage(_ language: String) {
        appLanguage = .init(rawValue: language) ?? .rus
    }

    func setAppTheme(_ theme: AppColorTheme) {
        appTheme = theme
    }

    func saveAuthData(_ info: AuthData) throws {
        authData = try JSONEncoder().encode(info)
    }

    func basicAuthInfo() throws -> AuthData {
        try JSONDecoder().decode(AuthData.self, from: authData)
    }

    func setUserNeedUpdate(_ newValue: Bool) {
        needUpdateUser = newValue
    }

    func saveUserInfo(_ info: UserResponse) throws {
        hasFriends = info.friendsCount.valueOrZero != .zero
        setHasSportsGrounds(info.usedSportsGroundsCount != .zero)
        setHasJournals(info.journalsCount.valueOrZero != .zero)
        if !isAuthorized { isAuthorized = true }
        userInfo = try JSONEncoder().encode(info)
        setUserNeedUpdate(false)
    }

    func saveFriendsIds(_ ids: [Int]) throws {
        hasFriends = !ids.isEmpty
        friendsIds = try JSONEncoder().encode(ids)
    }

    func saveFriendRequests(_ array: [UserResponse]) throws {
        friendRequests = try JSONEncoder().encode(array)
    }

    func saveBlacklist(_ array: [UserResponse]) throws {
        blacklist = try JSONEncoder().encode(array)
    }

    func setHasJournals(_ hasJournals: Bool) {
        self.hasJournals = hasJournals
    }

    func setHasSportsGrounds(_ isAddedGround: Bool) {
        switch (hasSportsGrounds, isAddedGround) {
        case (true, true), (false, false): break
        case (true, false):
            if mainUserInfo?.usedSportsGroundsCount == 1 {
                hasSportsGrounds = false
            }
        case (false, true):
            hasSportsGrounds = true
        }
    }

    func saveUnreadMessagesCount(_ count: Int) {
        unreadMessagesCount = count
    }

    func triggerLogout() {
        authData = .init()
        userInfo = .init()
        isAuthorized = false
        hasSportsGrounds = false
        try? saveFriendsIds([])
        try? saveFriendRequests([])
        try? saveBlacklist([])
        saveUnreadMessagesCount(0)
        setHasJournals(false)
        setUserNeedUpdate(true)
        setAppTheme(.system)
    }
}

private extension DefaultsService {
    enum Key: String {
        case isUserAuthorized, hasSportsGrounds, appTheme, appLanguage,
             authData, userInfo, friends, friendRequests, blacklist,
             hasJournals, needUpdateUser, hasFriends, unreadMessagesCount
    }
}

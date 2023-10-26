import SwiftUI
import SWModels
import Utils

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

    @AppStorage(Key.lastGroundsUpdateDateString.rawValue)
    private(set) var lastGroundsUpdateDateString = "2023-01-12T00:00:00"

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
            NSLocalizedString("usersCount", comment: ""),
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

    func setAppLanguage(_ language: AppLanguage) {
        appLanguage = language
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
        hasFriends = info.friendsCount ?? 0 != 0
        setHasSportsGrounds(info.usedSportsGroundsCount != 0)
        setHasJournals(info.journalsCount ?? 0 != 0)
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

    func didUpdateGrounds() {
        // Как и в методе `checkForRecentUpdates`, ставим дату с запасом в 5 минут
        lastGroundsUpdateDateString = DateFormatterService.fiveMinutesAgoDateString
    }

    func didUpdateCountries() {
        lastCountriesUpdateDate = .now
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
             hasJournals, needUpdateUser, hasFriends, unreadMessagesCount,
             lastGroundsUpdateDateString, lastCountriesUpdateDate
    }
}

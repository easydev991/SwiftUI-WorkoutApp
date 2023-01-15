import SwiftUI

@MainActor
protocol DefaultsProtocol: AnyObject {
    var mainUserInfo: UserResponse? { get }
    var mainUserCountryID: Int { get }
    var mainUserCityID: Int { get }
    var needUpdateUser: Bool { get }
    var isAuthorized: Bool { get }
    var friendRequestsList: [UserResponse] { get }
    var friendsIdsList: [Int] { get }
    var blacklistedUsers: [UserResponse] { get }
    var unreadMessagesCount: Int { get set }
    func saveAuthData(_ info: AuthData) throws
    func basicAuthInfo() throws -> AuthData
    func setUserNeedUpdate(_ newValue: Bool)
    func saveUserInfo(_ info: UserResponse) throws
    func saveFriendsIds(_ ids: [Int]) throws
    func saveFriendRequests(_ array: [UserResponse]) throws
    func saveBlacklist(_ array: [UserResponse]) throws
    func setHasJournals(_ hasJournals: Bool)
    func setHasSportsGrounds(_ hasGrounds: Bool)
    func triggerLogout()
}

@MainActor
final class DefaultsService: ObservableObject, DefaultsProtocol {
    @AppStorage(Key.needUpdateUser.rawValue)
    private(set) var needUpdateUser = false

    @AppStorage(Key.isUserAuthorized.rawValue)
    private(set) var isAuthorized = false

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
    var unreadMessagesCount = 0

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

    func setHasSportsGrounds(_ hasGrounds: Bool) {
        self.hasSportsGrounds = hasGrounds
    }

    func triggerLogout() {
        authData = .init()
        userInfo = .init()
        friendsIds = .init()
        friendRequests = .init()
        isAuthorized = false
        hasFriends = false
        hasJournals = false
        hasSportsGrounds = false
        needUpdateUser = true
    }
}

private extension DefaultsService {
    enum Key: String {
        case isUserAuthorized, hasSportsGrounds,
             authData, userInfo, friends, friendRequests, blacklist,
             hasJournals, needUpdateUser, hasFriends, unreadMessagesCount
    }
}

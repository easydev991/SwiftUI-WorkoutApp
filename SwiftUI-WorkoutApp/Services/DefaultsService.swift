import SwiftUI

final class DefaultsService: ObservableObject {
    @AppStorage(Key.needUpdateUser.rawValue)
    private(set) var needUpdateUser = false

    @AppStorage(Key.mainUserID.rawValue)
    private(set) var mainUserID = Int.zero

    @AppStorage(Key.mainUserCountry.rawValue)
    private(set) var mainUserCountry = Int.zero

    @AppStorage(Key.mainUserCity.rawValue)
    private(set) var mainUserCity = Int.zero

    @AppStorage(Key.isUserAuthorized.rawValue)
    private(set) var isAuthorized = false

    @AppStorage(Key.showWelcome.rawValue)
    private(set) var showWelcome = true

    @AppStorage(Key.authData.rawValue)
    private var authData = Data()

    @AppStorage(Key.userInfo.rawValue)
    private var userInfo = Data()

    @AppStorage(Key.friends.rawValue)
    private var friendsIds = Data()

    @AppStorage(Key.friendRequests.rawValue)
    private var friendRequests = Data()

    @AppStorage(Key.hasSportsGrounds.rawValue)
    private(set) var hasSportsGrounds = false

    @AppStorage(Key.hasJournals.rawValue)
    private(set) var hasJournals = false

    @AppStorage(Key.hasFriends.rawValue)
    private(set) var hasFriends = false

    func setWelcomeShown() {
        showWelcome = false
    }

    @MainActor
    func triggerLogout() {
        authData = .init()
        userInfo = .init()
        friendsIds = .init()
        friendRequests = .init()
        mainUserID = .zero
        mainUserCountry = .zero
        mainUserCity = .zero
        isAuthorized = false
        showWelcome = true
    }

    @MainActor
    func saveAuthData(_ info: AuthData) {
        if let data = try? JSONEncoder().encode(info) {
            authData = data
        }
    }

    var basicAuthInfo: AuthData {
        if let info = try? JSONDecoder().decode(AuthData.self, from: authData) {
            return info
        } else {
            return .emptyValue
        }
    }

#warning("TODO: убрать после интеграции с БД")
    @MainActor
    func setUserNeedUpdate(_ newValue: Bool) {
        needUpdateUser = newValue
    }

    @MainActor
    func saveUserInfo(_ info: UserResponse) {
        mainUserID = info.userID.valueOrZero
        mainUserCountry = info.countryID.valueOrZero
        mainUserCity = info.cityID.valueOrZero
        hasFriends = info.friendsCount.valueOrZero != .zero
        setHasSportsGrounds(info.usedSportsGroundsCount != .zero)
        setHasJournals(info.journalsCount.valueOrZero != .zero)
        if !isAuthorized {
            showWelcome = false
            isAuthorized = true
        }
        if let data = try? JSONEncoder().encode(info) {
            userInfo = data
            setUserNeedUpdate(false)
        }
    }

    var mainUserInfo: UserResponse? {
        if let info = try? JSONDecoder().decode(UserResponse.self, from: userInfo) {
            return info
        } else {
            return nil
        }
    }

    @MainActor
    func saveFriendsIds(_ ids: [Int]) {
        hasFriends = !ids.isEmpty
        if let data = try? JSONEncoder().encode(ids) {
            friendsIds = data
        }
    }

    @MainActor
    var friendsIdsList: [Int] {
        if let array = try? JSONDecoder().decode([Int].self, from: friendsIds) {
            return array
        } else {
            return []
        }
    }

    @MainActor
    func saveFriendRequests(_ array: [UserResponse]) {
        if let data = try? JSONEncoder().encode(array) {
            friendRequests = data
        }
    }

    @MainActor
    var friendRequestsList: [UserResponse] {
        if let array = try? JSONDecoder().decode([UserResponse].self, from: friendRequests) {
            return array
        } else {
            return []
        }
    }

    @MainActor
    func setHasJournals(_ hasJournals: Bool) {
        self.hasJournals = hasJournals
    }

    @MainActor
    func setHasSportsGrounds(_ hasGrounds: Bool) {
        self.hasSportsGrounds = hasGrounds
    }
}

private extension DefaultsService {
    enum Key: String {
        case mainUserID, isUserAuthorized, showWelcome,
             authData, userInfo, friends, friendRequests,
             hasJournals, mainUserCountry, mainUserCity,
             needUpdateUser, hasSportsGrounds, hasFriends
    }
}

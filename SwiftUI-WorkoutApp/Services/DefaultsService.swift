import Combine
import SwiftUI
import SWKeychain
import SWModels
import SWNetworkClient

@MainActor
final class DefaultsService: ObservableObject {
    let authHelper: AuthHelper
    private var cancellable: AnyCancellable?

    init(authHelper: AuthHelper) {
        self.authHelper = authHelper
        self.cancellable = authHelper.authTokenPublisher
            .dropFirst()
            .sink { [weak self] token in
                guard let self, token == nil else { return }
                triggerLogout(manually: false)
            }
    }

    var appIconBadgeCount: Int {
        unreadMessagesCount + friendRequestsList.count
    }

    @AppStorage(Key.needUpdateUser.rawValue)
    private(set) var needUpdateUser = false

    var isAuthorized: Bool { mainUserInfo != nil }

    @AppStorage(Key.appTheme.rawValue)
    private(set) var appTheme = AppColorTheme.system

    @AppStorage(Key.userInfo.rawValue)
    private var userInfo = Data()

    @AppStorage(Key.friends.rawValue)
    private var friendsIds = Data()

    @AppStorage(Key.friendRequests.rawValue)
    private var friendRequests = Data()

    @AppStorage(Key.blacklist.rawValue)
    private var blacklist = Data()

    var hasParks: Bool { mainUserInfo?.hasUsedParks == true }

    var hasFriends: Bool { !friendsIdsList.isEmpty }

    @AppStorage(Key.unreadMessagesCount.rawValue)
    private(set) var unreadMessagesCount = 0

    @AppStorage(Key.lastCountriesUpdateDate.rawValue)
    private(set) var lastCountriesUpdateDate = Date(timeIntervalSince1970: 1673470800.0)

    @AppStorage(Key.parksFilter.rawValue) var parksFilter = ParkFilterModel()

    var mainUserInfo: UserResponse? {
        try? JSONDecoder().decode(UserResponse.self, from: userInfo)
    }

    var mainUserCityId: Int {
        mainUserInfo?.cityId ?? 0
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

    var profileBadgeCount: Int {
        friendRequestsList.count + (mainUserInfo?.badgeValue ?? 0)
    }

    func setAppTheme(_ theme: AppColorTheme) {
        guard appTheme != theme else { return }
        appTheme = theme
    }

    func saveAuthData(_ model: AuthData) {
        guard let authHelperImp = authHelper as? AuthHelperImp else {
            return
        }
        authHelperImp.saveAuthData(model)
    }

    func getUserPassword() throws -> String {
        guard let authHelperImp = authHelper as? AuthHelperImp else {
            throw StorageError.noAuthData
        }
        return try authHelperImp.getUserPassword()
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
        guard unreadMessagesCount != count else { return }
        unreadMessagesCount = count
    }

    func didUpdateCountries() {
        lastCountriesUpdateDate = .now
    }

    /// Обновляет сохраненный список идентификаторов друзей главного пользователя
    ///
    /// Если друга удаляют, то удаляем его `id` из списка сохраненных друзей
    /// - Parameters:
    ///   - friendId: `id` друга
    ///   - action: действие с другом (отправка заявки/удаление)
    func updateFriendIds(friendId: Int, action: FriendAction) {
        var newList = friendsIdsList
        guard case .remove = action else { return }
        newList.removeAll(where: { $0 == friendId })
        try? saveFriendsIds(newList)
    }

    func triggerLogout(manually: Bool = true) {
        if manually {
            authHelper.triggerLogout()
        }
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
            hasParks: hasParks,
            hasFriends: hasFriends
        )
    }
}

extension DefaultsService {
    enum StorageError: Error, LocalizedError {
        case noAuthData

        var errorDescription: String? {
            switch self {
            case .noAuthData: "В keychain нет данных авторизации"
            }
        }
    }
}

private extension DefaultsService {
    enum Key: String {
        case appTheme, authData, userInfo, friends, friendRequests, blacklist, needUpdateUser, unreadMessagesCount, lastCountriesUpdateDate,
             parksFilter
    }
}

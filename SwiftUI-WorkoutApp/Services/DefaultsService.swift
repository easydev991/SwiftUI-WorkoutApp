import SwiftUI
import SWKeychain
import SWModels

@MainActor
final class DefaultsService: ObservableObject, DefaultsProtocol {
    init() {
        migrateAuthDataFromUserDefaults()
    }

    var authToken: String? { authData?.token }
    var appIconBadgeCount: Int {
        unreadMessagesCount + friendRequestsList.count
    }

    @AppStorage(Key.needUpdateUser.rawValue)
    private(set) var needUpdateUser = false

    var isAuthorized: Bool { mainUserInfo != nil }

    @AppStorage(Key.appTheme.rawValue)
    private(set) var appTheme = AppColorTheme.system

    @KeychainWrapper(Key.authData.rawValue)
    private var authData: AuthData?

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

    var mainUserInfo: UserResponse? {
        try? JSONDecoder().decode(UserResponse.self, from: userInfo)
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
        guard appTheme != theme else { return }
        appTheme = theme
    }

    func saveAuthData(_ model: AuthData) {
        authData = model
    }

    func getUserPassword() throws -> String {
        guard let password = authData?.password else {
            throw StorageError.noAuthData
        }
        return password
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
    ///   - friendID: `id` друга
    ///   - action: действие с другом (отправка заявки/удаление)
    func updateFriendIds(friendID: Int, action: FriendAction) {
        var newList = friendsIdsList
        guard case .removeFriend = action else { return }
        newList.removeAll(where: { $0 == friendID })
        try? saveFriendsIds(newList)
    }

    func triggerLogout() {
        authData = nil
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
        case appTheme, authData, userInfo, friends, friendRequests, blacklist, needUpdateUser, unreadMessagesCount, lastCountriesUpdateDate
    }
}

private extension DefaultsService {
    /// Старая модель, которая хранилась в `UserDefaults`
    struct LegacyAuthData: Codable {
        let password: String
        let token: String?

        var login: String? {
            guard let token else { return nil }
            guard let data = Data(base64Encoded: token),
                  let decodedString = String(data: data, encoding: .utf8)
            else { return nil }
            let components = decodedString.components(separatedBy: ":")
            guard components.count >= 2 else { return nil }
            return components[0]
        }
    }

    /// Переносит авторизационные данные из `UserDefaults` в `keychain`
    func migrateAuthDataFromUserDefaults() {
        guard authData == nil,
              let legacyData = UserDefaults.standard.data(forKey: Key.authData.rawValue)
        else { return }
        UserDefaults.standard.removeObject(forKey: Key.authData.rawValue)
        guard let oldModel = try? JSONDecoder().decode(LegacyAuthData.self, from: legacyData),
              let login = oldModel.login
        else { return }
        authData = .init(login: login, password: oldModel.password)
    }
}

//
//  UserDefaultsService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import SwiftUI

final class UserDefaultsService: ObservableObject {
    @AppStorage(Key.mainUserID.rawValue)
    private(set) var mainUserID = Int.zero

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

    /// Ставим `true` при смене состояния приложения на `inactive`
    var needUpdateUser = true

    @MainActor
    func setMainUserID(_ id: Int) {
        mainUserID = id
    }

    func setWelcomeShown() {
        showWelcome = false
    }

    @MainActor
    func setUserLoggedIn() {
        showWelcome = false
        isAuthorized = true
    }

    func triggerLogout() {
        authData = .init()
        userInfo = .init()
        friendRequests = .init()
        mainUserID = .zero
        showWelcome = true
        isAuthorized = false
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

    @MainActor
    func saveUserInfo(_ info: UserResponse) {
        if let data = try? JSONEncoder().encode(info) {
            userInfo = data
            needUpdateUser = false
        }
    }

    @MainActor
    var mainUserInfo: UserResponse? {
        if let info = try? JSONDecoder().decode(UserResponse.self, from: userInfo) {
            return info
        } else {
            return nil
        }
    }

    @MainActor
    func saveFriends(_ friendsIds: [UserResponse]) {
        if let data = try? JSONEncoder().encode(friendsIds) {
            self.friendsIds = data
        }
    }

    @MainActor
    var friendsList: [UserResponse] {
        if let array = try? JSONDecoder().decode([UserResponse].self, from: friendsIds) {
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
}

private extension UserDefaultsService {
    enum Key: String {
        case mainUserID, isUserAuthorized,showWelcome,
             authData, userInfo, friends, friendRequests
    }
}

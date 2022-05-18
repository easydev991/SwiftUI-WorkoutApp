//
//  DefaultsService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import SwiftUI

final class DefaultsService: ObservableObject {
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

    @MainActor
    func saveUserInfo(_ info: UserResponse) {
        mainUserID = info.userID.valueOrZero
        if !isAuthorized {
            showWelcome = false
            isAuthorized = true
        }
        if let data = try? JSONEncoder().encode(info) {
            userInfo = data
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
    func saveFriendsIds(_ ids: [Int]) {
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
}

private extension DefaultsService {
    enum Key: String {
        case mainUserID, isUserAuthorized,
             showWelcome, authData, userInfo,
             friends, friendRequests
    }
}

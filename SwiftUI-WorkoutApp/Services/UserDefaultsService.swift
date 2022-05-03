//
//  UserDefaultsService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import SwiftUI

final class UserDefaultsService: ObservableObject {
    @AppStorage(Key.mainUserID.rawValue) private(set) var mainUserID = Int.zero
    @AppStorage(Key.isUserAuthorized.rawValue) private(set) var isUserAuthorized = false
    @AppStorage(Key.showWelcome.rawValue) private(set) var showWelcome = true
    @AppStorage(Key.authData.rawValue) private var authData = Data()
    @AppStorage(Key.userInfo.rawValue) private var userInfo = Data()

    @MainActor func setMainUserID(_ id: Int) {
        mainUserID = id
    }

    @MainActor func setWelcomeShown() {
        showWelcome = false
    }

    @MainActor func setUserLoggedIn() {
        showWelcome = false
        isUserAuthorized = true
    }

    func triggerLogout() {
        authData = .init()
        userInfo = .init()
        mainUserID = .zero
        showWelcome = true
        isUserAuthorized = false
    }

    @MainActor func saveAuthData(_ info: AuthData) {
        if let data = try? JSONEncoder().encode(info) {
            authData = data
        }
    }

    func getAuthData() -> AuthData {
        if let info = try? JSONDecoder().decode(AuthData.self, from: authData) {
            return info
        } else {
            return .emptyValue
        }
    }

    @MainActor func saveUserInfo(_ info: UserResponse) {
        if let data = try? JSONEncoder().encode(info) {
            userInfo = data
        }
    }

    @MainActor func getUserInfo() -> UserResponse? {
        if let info = try? JSONDecoder().decode(UserResponse.self, from: userInfo) {
            return info
        } else {
            return nil
        }
    }
}

private extension UserDefaultsService {
    enum Key: String {
        case mainUserID, isUserAuthorized, showWelcome, authData, userInfo
    }
}

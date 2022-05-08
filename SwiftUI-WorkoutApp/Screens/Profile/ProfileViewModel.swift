//
//  ProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class ProfileViewModel: ObservableObject {
    func checkFriendRequests(with defaults: UserDefaultsService) async {
        if defaults.isAuthorized, defaults.needUpdateUser,
           let friendRequests = try? await APIService(with: defaults).getFriendRequests() {
            await defaults.saveFriendRequests(friendRequests)
        }
    }
}

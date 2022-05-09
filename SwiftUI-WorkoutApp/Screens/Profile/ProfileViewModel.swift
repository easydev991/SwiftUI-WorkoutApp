//
//  ProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    func checkFriendRequests(with defaults: UserDefaultsService) async {
        if defaults.isAuthorized, defaults.needUpdateUser {
            try? await APIService(with: defaults).getFriendRequests()
        }
    }
}

//
//  UserProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class UserProfileViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var requestedFriendship = false
    @Published private(set) var friendActionOption = Constants.FriendAction.sendFriendRequest
    @Published private(set) var user = UserModel.emptyValue
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeUserInfo(
        for userID: Int,
        with defaults: DefaultsService,
        refresh: Bool = false
    ) async {
        let isMainUser = userID == defaults.mainUserID
        if user.id != .zero, !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        if isMainUser, !refresh,
           let mainUserInfo = defaults.mainUserInfo {
            user = .init(mainUserInfo)
        } else {
            do {
                let info = try await APIService(with: defaults).getUserByID(userID)
                if info.userID == nil {
                    errorMessage = Constants.Alert.cannotReadData
                    if !refresh { isLoading.toggle() }
                    return
                }
                if !isMainUser {
                    friendActionOption = defaults.friendsIdsList.contains(userID)
                    ? .removeFriend
                    : .sendFriendRequest
                }
                user = .init(info)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func checkFriendRequests(with defaults: DefaultsService) async {
        try? await APIService(with: defaults).getFriendRequests()
    }

    @MainActor
    func friendAction(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isSuccess = try await APIService(with: defaults).friendAction(userID: user.id, option: friendActionOption)
            if isSuccess {
                switch friendActionOption {
                case .sendFriendRequest:
                    requestedFriendship.toggle()
                case .removeFriend:
                    friendActionOption = .sendFriendRequest
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

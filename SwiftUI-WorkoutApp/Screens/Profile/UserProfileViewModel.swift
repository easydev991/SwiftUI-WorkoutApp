//
//  UserProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class UserProfileViewModel: ObservableObject {
    private(set) var isMainUser = false
    @Published private(set) var isLoading = false
    @Published private(set) var requestedFriendship = false
    @Published private(set) var friendActionOption = Constants.FriendAction.sendFriendRequest
    @Published private(set) var user = UserModel.emptyValue
    @Published private(set) var errorMessage = ""
    var addedSportsGrounds: Int {
#warning("TODO: маппить из списка площадок, т.к. сервер не присылает")
        return user.addedSportsGrounds
    }

    @MainActor
    func makeUserInfo(
        for userID: Int,
        with defaults: UserDefaultsService,
        refresh: Bool = false
    ) async {
        errorMessage = ""
        isMainUser = userID == defaults.mainUserID
        if user.id != .zero, !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        if isMainUser, !refresh,
           let mainUserInfo = defaults.mainUserInfo {
            user = .init(mainUserInfo)
        } else {
            do {
                guard let info = try await APIService(with: defaults).getUserByID(userID) else {
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
    func checkFriendRequests(with defaults: UserDefaultsService) async {
        try? await APIService(with: defaults).getFriendRequests()
    }

    @MainActor
    func friendAction(with defaults: UserDefaultsService) async {
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

    func friendRequestedAlertOKAction() {
        print("--- заглушка")
    }
}

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
#warning("TODO: добавить состояние *Удалить из друзей*")
    @Published private(set) var isAddFriendButtonEnabled = false
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
        isLoading.toggle()
        if isMainUser, !refresh,
           let mainUserInfo = defaults.mainUserInfo {
            user = .init(mainUserInfo)
        } else {
            do {
                guard let info = try await APIService(with: defaults).getUserByID(userID) else {
                    errorMessage = Constants.Alert.cannotReadData
                    isLoading.toggle()
                    return
                }
                if !isMainUser,
                   !defaults.friendsIdsList.contains(userID) {
                    isAddFriendButtonEnabled.toggle()
                }
                user = .init(info)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        isLoading.toggle()
    }

    @MainActor
    func checkFriendRequests(with defaults: UserDefaultsService) async {
        if defaults.isAuthorized {
            try? await APIService(with: defaults).getFriendRequests()
        }
    }

    func sendFriendRequest() {
#warning("TODO: интеграция с сервером")
        requestedFriendship = true
    }

    func friendRequestedAlertOKAction() {
        isAddFriendButtonEnabled.toggle()
    }
}

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
    @Published private(set) var isAddFriendButtonEnabled = true
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
        if isMainUser && !defaults.needUpdateUser && !refresh
            || (user.id != .zero && !refresh) {
            return
        }
        isLoading.toggle()
        if isMainUser,
           let mainUserInfo = defaults.getUserInfo() {
            user = .init(mainUserInfo)
            isLoading.toggle()
            return
        }
        do {
            guard let info = try await APIService(with: defaults).getUserByID(userID) else {
                errorMessage = Constants.Alert.cannotReadData
                isLoading.toggle()
                return
            }
            user = .init(info)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func sendFriendRequest() {
#warning("TODO: интеграция с сервером")
        requestedFriendship = true
    }

    func friendRequestedAlertOKAction() {
        isAddFriendButtonEnabled = false
    }
}

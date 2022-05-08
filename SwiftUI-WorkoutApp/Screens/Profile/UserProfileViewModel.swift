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

    func makeUserInfo(for userID: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        if isLoading
            || (isMainUser && !defaults.needUpdateUser)
            || (!isMainUser && user.id != .zero) {
            return
        }
        if userID == defaults.mainUserID,
           let mainUserInfo = await defaults.getUserInfo() {
            await MainActor.run {
                user = .init(mainUserInfo)
                isMainUser = true
            }
            return
        }
        await MainActor.run { isLoading.toggle() }
        do {
            guard let info = try await APIService(with: defaults).getUserByID(userID) else {
                await MainActor.run {
                    errorMessage = Constants.Alert.cannotReadData
                    isLoading.toggle()
                }
                return
            }
            await MainActor.run {
                user = .init(info)
                isMainUser = user.id == defaults.mainUserID
                isLoading.toggle()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading.toggle()
            }
        }
    }

    func sendFriendRequest() {
#warning("TODO: интеграция с сервером")
        requestedFriendship = true
    }

    func friendRequestedAlertOKAction() {
        isAddFriendButtonEnabled = false
    }
}

//
//  PersonProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class PersonProfileViewModel: ObservableObject {
    private let userID: Int
    private var isMainUser = false
    private let countryCityService = ShortAddressService()

    @Published var isLoading = false
    @Published var requestedFriendship = false
    @Published var isAddFriendButtonEnabled = true
    @Published var user: UserModel? = nil
    @Published var errorResponse = ""

    var showCommunication: Bool { !isMainUser }
    var showSettingsButton: Bool { isMainUser }
    var userShortAddress: String {
        let countryID = (user?.countryID).valueOrZero
        let cityID = (user?.cityID).valueOrZero
        return countryCityService.addressFor(countryID, cityID)
    }
    var addedSportsGrounds: Int {
#warning("TODO: маппить из списка площадок, т.к. сервер не присылает")
        return (user?.addedSportsGrounds).valueOrZero
    }

    init(userID: Int) {
        self.userID = userID
    }

    func makeUserInfo(with userDefaults: UserDefaultsService) async {
        errorResponse = ""
        if isLoading || user != nil {
            return
        }
        if userID == userDefaults.mainUserID,
           let mainUserInfo = await userDefaults.getUserInfo() {
            
            await MainActor.run {
                user = .init(mainUserInfo)
                isMainUser = true
            }
            return
        }
        await MainActor.run { isLoading = true }
        do {
            guard let userResponse = try await APIService(with: userDefaults).getUserByID(userID) else {
                await MainActor.run {
                    errorResponse = "Не удается прочитать загруженные данные"
                    isLoading = false
                }
                return
            }
            await MainActor.run {
                user = .init(userResponse)
                isMainUser = userResponse.userID == userDefaults.mainUserID
                isLoading = false
            }
        } catch {
            print("--- makeUserInfo error: \(error)")
            await MainActor.run {
                errorResponse = error.localizedDescription
                isLoading = false
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

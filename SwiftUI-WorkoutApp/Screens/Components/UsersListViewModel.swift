//
//  UsersListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 07.05.2022.
//

import Foundation

final class UsersListViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var friendRequests = [UserModel]()
    @Published private(set) var errorMessage = ""
    @Published private(set) var isLoading = false

    @MainActor
    func makeInfo(
        for mode: UsersListView.Mode,
        with defaults: DefaultsService,
        refresh: Bool = false
    ) async {
        if (!users.isEmpty || isLoading) && !refresh { return }
        switch mode {
        case let .friends(userID):
            await makeFriendsList(for: userID, with: defaults, refresh: refresh)
        case let .sportsGroundVisitors(list):
            users = list.map(UserModel.init)
        }
    }

    @MainActor
    func respondToFriendRequest(
        from userID: Int,
        with defaults: DefaultsService,
        accept: Bool
    ) async {
        isLoading.toggle()
        do {
            let isSuccess = try await APIService(with: defaults).respondToFriendRequest(from: userID, accept: accept)
            if isSuccess {
                self.friendRequests = defaults.friendRequestsList.map(UserModel.init)
            }
        } catch {
#if DEBUG
            print("--- error acceptFriendRequest: \(error)")
#endif
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension UsersListViewModel {
    @MainActor
    func makeFriendsList(
        for id: Int,
        with defaults: DefaultsService,
        refresh: Bool
    ) async {
        let isMainUser = id == defaults.mainUserID
        let service = APIService(with: defaults)
        if !refresh { isLoading.toggle() }
        do {
            if isMainUser {
                await checkFriendRequests(with: defaults, refresh: refresh)
            }
            let friends = try await service.getFriendsForUser(id: id)
            users = friends.map(UserModel.init)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func checkFriendRequests(
        with defaults: DefaultsService,
        refresh: Bool
    ) async {
        if defaults.friendRequestsList.isEmpty || refresh {
            try? await APIService(with: defaults).getFriendRequests()
        }
        friendRequests = defaults.friendRequestsList.map(UserModel.init)
    }
}

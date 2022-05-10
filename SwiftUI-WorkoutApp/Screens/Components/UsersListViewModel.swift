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

    func makeInfo(
        for mode: UsersListView.Mode,
        with defaults: UserDefaultsService,
        refresh: Bool = false
    ) async {
        if (!users.isEmpty || isLoading) && !refresh { return }
        switch mode {
        case let .friends(userID):
            await makeFriendsList(for: userID, with: defaults, refresh: refresh)
        case let .sportsGroundVisitors(groundID):
            await makeParticipantsList(for: groundID, with: defaults, refresh: refresh)
        }
    }

    @MainActor
    func acceptFriendRequest(
        from userID: Int,
        with defaults: UserDefaultsService
    ) async {
        do {
            let isSuccess = try await APIService(with: defaults).acceptFriendRequest(from: userID)
            if isSuccess {
                self.friendRequests = defaults.friendRequestsList.map(UserModel.init)
            }
        } catch {
            print("--- error acceptFriendRequest: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func declineFriendRequest(from userID: Int) async {

    }

    deinit {
        print("--- deinited UsersListViewModel")
    }
}

private extension UsersListViewModel {
    @MainActor
    func makeFriendsList(
        for id: Int,
        with defaults: UserDefaultsService,
        refresh: Bool
    ) async {
        errorMessage = ""
        let isMainUser = id == defaults.mainUserID
        let service = APIService(with: defaults)
        if !refresh { isLoading.toggle() }
        do {
            if isMainUser {
                await checkFriendRequests(with: defaults, refresh: refresh)
            }
            if let friends = try await service.getFriendsForUser(id: id) {
                users = friends.map(UserModel.init)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func makeParticipantsList(
        for id: Int,
        with defaults: UserDefaultsService,
        refresh: Bool
    ) async {
        errorMessage = ""
        let _ = APIService(with: defaults)
        if !refresh { isLoading.toggle() }
#warning("TODO: интеграция с сервером")
        print("--- получить список тренирующихся на площадке с номером \(id)")
    }

    @MainActor
    func checkFriendRequests(
        with defaults: UserDefaultsService,
        refresh: Bool
    ) async {
        if defaults.friendRequestsList.isEmpty || refresh {
            try? await APIService(with: defaults).getFriendRequests()
        }
        self.friendRequests = defaults.friendRequestsList.map(UserModel.init)
    }
}

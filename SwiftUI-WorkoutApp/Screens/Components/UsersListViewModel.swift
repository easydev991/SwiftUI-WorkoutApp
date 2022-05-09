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

    func makeInfo(for mode: UsersListView.Mode, with defaults: UserDefaultsService) async {
        if !users.isEmpty || isLoading { return }
        switch mode {
        case let .friends(userID):
            await makeFriendsList(for: userID, with: defaults)
        case let .sportsGroundVisitors(groundID):
            await makeParticipantsList(for: groundID, with: defaults)
        }
    }

    deinit {
        print("--- deinited UsersListViewModel")
    }
}

private extension UsersListViewModel {
    @MainActor
    func makeFriendsList(for id: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        let isMainUser = id == defaults.mainUserID
        let service = APIService(with: defaults)
        isLoading.toggle()
        do {
            if isMainUser {
                self.friendRequests = defaults.friendRequestsList.map { UserModel($0) }
            }
            if let friends = try await service.getFriendsForUser(id: id) {
                users = friends.map { UserModel($0) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func makeParticipantsList(for id: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        let _ = APIService(with: defaults)
        isLoading.toggle()
#warning("TODO: интеграция с сервером")
        print("--- получить список тренирующихся на площадке с номером \(id)")
    }
}

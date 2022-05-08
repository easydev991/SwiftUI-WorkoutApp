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
    func makeFriendsList(for id: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        let isMainUser = id == defaults.mainUserID
        let service = APIService(with: defaults)
        await MainActor.run { isLoading.toggle() }
        do {
            if isMainUser, let friendRequests = await defaults.getFriendRequests() {
                await MainActor.run {
                    self.friendRequests = friendRequests.map { UserModel($0) }
                }
            }
            if let friends = try await service.getFriendsForUser(id: id) {
                await MainActor.run {
                    users = friends.map { UserModel($0) }
                    isLoading.toggle()
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading.toggle()
            }
        }
    }

    func makeParticipantsList(for id: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        let _ = APIService(with: defaults)
        await MainActor.run { isLoading.toggle() }
#warning("TODO: интеграция с сервером")
        print("--- получить список тренирующихся на площадке с номером \(id)")
    }
}

//
//  PersonsListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 07.05.2022.
//

import Foundation

final class PersonsListViewModel: ObservableObject {
    @Published var persons = [UserResponse]()
    @Published var errorMessage = ""
    @Published var isLoading = false

    func makeInfo(for mode: PersonsListView.Mode, with defaults: UserDefaultsService) async {
        switch mode {
        case let .friends(userID):
            await makeFriends(for: userID, with: defaults)
        case let .sportsGroundVisitors(groundID):
            await makeParticipants(for: groundID, with: defaults)
        }
    }

    deinit {
        print("--- deinited PersonsListViewModel")
    }
}

private extension PersonsListViewModel {
    func makeFriends(for id: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        let service = APIService(with: defaults)
        await MainActor.run { isLoading = true }
        do {
            if let array = try await service.getFriendsForUser(id: id) {
                await MainActor.run {
                    persons = array
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func makeParticipants(for id: Int, with defaults: UserDefaultsService) async {
        errorMessage = ""
        let _ = APIService(with: defaults)
        await MainActor.run { isLoading = true }
#warning("TODO: интеграция с сервером")
        print("--- получить список тренирующихся на площадке с номером \(id)")
    }
}

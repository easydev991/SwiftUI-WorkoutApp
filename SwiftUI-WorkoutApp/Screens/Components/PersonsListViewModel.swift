//
//  PersonsListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 07.05.2022.
//

import Foundation

final class PersonsListViewModel: ObservableObject {
    private let mode: Mode
    @Published var persons = [UserResponse]()
    @Published var errorMessage = ""
    @Published var isLoading = false

    init(mode: Mode) {
        self.mode = mode
    }

    func makePersons(defaults: UserDefaultsService) async {
        errorMessage = ""
        let service = APIService(with: defaults)
        await MainActor.run { isLoading = true }
        switch mode {
        case let .friends(userID):
            do {
                if let array = try await service.getFriendsForUser(id: userID) {
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
        case let .sportsGroundVisitors(groundID):
    #warning("TODO: интеграция с сервером")
            print("--- получить список тренирующихся на площадке с номером \(groundID)")
            break
        }
    }

    deinit {
        print("--- deinited PersonsListViewModel")
    }
}

extension PersonsListViewModel {
    enum Mode {
        case friends(userID: Int)
        case sportsGroundVisitors(groundID: Int)
    }
}

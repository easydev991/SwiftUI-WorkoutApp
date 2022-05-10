//
//  SearchUsersViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 10.05.2022.
//

import Foundation

final class SearchUsersViewModel: ObservableObject {
    @Published private(set) var users = [UserModel]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func searchFor(name: String, with defaults: UserDefaultsService) async {
        errorMessage = ""
        if isLoading { return }
        isLoading.toggle()
        do {
            let result = try await APIService(with: defaults).findUsers(with: name)
            users = result.map(UserModel.init)
        } catch {
            print("--- error with search: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }
}

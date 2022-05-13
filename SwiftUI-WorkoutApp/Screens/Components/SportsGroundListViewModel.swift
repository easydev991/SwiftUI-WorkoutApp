//
//  SportsGroundListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 13.05.2022.
//

import Foundation

final class SportsGroundListViewModel: ObservableObject {
    @Published private(set) var list = [SportsGround]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func makeSportsGroundsForUser(_ userID: Int, refresh: Bool, with defaults: UserDefaultsService) async {
        if isLoading || (!list.isEmpty && !refresh) { return }
        if !refresh { isLoading.toggle() }
        do {
            list = try await APIService(with: defaults).getSportsGroundsForUser(userID)
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    func clearErrorMessage() {
        errorMessage = ""
    }
}

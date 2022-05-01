//
//  PersonProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class PersonProfileViewModel: ObservableObject {
    @Published var requestedFriendship = false
    @Published var isAddFriendButtonEnabled = true

    func sendFriendRequest() {
#warning("TODO: интеграция с сервером")
        requestedFriendship = true
    }

    func friendRequestedAlertOKAction() {
        isAddFriendButtonEnabled = false
    }
}

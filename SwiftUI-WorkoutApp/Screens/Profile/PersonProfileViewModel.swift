//
//  PersonProfileViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class PersonProfileViewModel: ObservableObject {
    #warning("TODO: интеграция с сервером")
    @Published var alertTitle = "Запрос отправлен!"
    @Published var isFriendRequestSent = false
    @Published var isAddFriendButtonEnabled = true

    func sendFriendRequest() {
        print("Отправляем запрос на добавление в друзья")
        isFriendRequestSent = true
    }

    func friendRequestedAlertOKAction() {
        isAddFriendButtonEnabled = false
    }
}

//
//  MessagingViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import Foundation

final class MessagingViewModel: ObservableObject {
    @Published private(set) var isSuccess = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func send(_ message: String, to userID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).sendMessage(message, to: userID) {
                isSuccess.toggle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

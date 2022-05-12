//
//  CreateCommentViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import Foundation

final class CreateCommentViewModel: ObservableObject {
    @Published var commentText = ""
    @Published private(set) var isSuccess = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func addComment(to groundID: Int, defaults: UserDefaultsService) async {
        errorMessage = ""
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).addComment(to: groundID, comment: commentText)
            if isOk { isSuccess.toggle() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func closedErrorAlert() {
        errorMessage = ""
    }

    deinit {
        print("--- deinited comment VM")
    }
}

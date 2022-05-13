//
//  CreateOrEditCommentViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import Foundation

final class CreateOrEditCommentViewModel: ObservableObject {
    @Published private(set) var isSuccess = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func addComment(to groundID: Int, comment: String, defaults: UserDefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).addComment(to: groundID, comment: comment)
            if isOk { isSuccess.toggle() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func editComment(for groundID: Int, commentID: Int, newComment: String, with defaults: UserDefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).editComment(for: groundID, commentID: commentID, newComment: newComment)
            if isOk { isSuccess.toggle() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func closedErrorAlert() { errorMessage = "" }
}

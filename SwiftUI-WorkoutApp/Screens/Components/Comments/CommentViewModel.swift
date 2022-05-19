//
//  CreateOrEditCommentViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 11.05.2022.
//

import Foundation

final class CommentViewModel: ObservableObject {
    @Published private(set) var isSuccess = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    @MainActor
    func addComment(_ mode: CommentView.Mode, comment: String, defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk: Bool
            switch mode {
            case let .ground(id):
                isOk = try await APIService(with: defaults).addComment(
                    to: .ground(id: id), comment: comment
                )
            case let .event(id):
                isOk = try await APIService(with: defaults).addComment(
                    to: .event(id: id), comment: comment
                )
            default: isOk = false
            }
            if isOk { isSuccess.toggle() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func editComment(for groundID: Int, commentID: Int, newComment: String, with defaults: DefaultsService) async {
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

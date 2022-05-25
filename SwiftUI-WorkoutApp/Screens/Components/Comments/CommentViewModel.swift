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
            case let .newForGround(id):
                isOk = try await APIService(with: defaults).addComment(
                    to: .ground(id: id), comment: comment
                )
            case let .newForEvent(id):
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
    func editComment(for mode: CommentView.Mode, newComment: String, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            let isOk: Bool
            switch mode {
            case let .editGround(info):
                isOk = try await APIService(with: defaults).editComment(for: .ground(id: info.objectID), commentID: info.commentID, newComment: newComment)
            case let .editEvent(info):
                isOk = try await APIService(with: defaults).editComment(for: .event(id: info.objectID), commentID: info.commentID, newComment: newComment)
            default: isOk = false
            }
            if isOk { isSuccess.toggle() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func closedErrorAlert() { errorMessage = "" }
}

import SwiftUI

/// Экран для создания и изменения комментария к мероприятию или площадке
struct CommentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = CommentViewModel()
    @State private var commentText = ""
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var addCommentTask: Task<Void, Never>?
    @State private var editCommentTask: Task<Void, Never>?
    @FocusState private var isFocused

    private let mode: Mode
    private var oldCommentText: String?
    @Binding private var isCommentSent: Bool

    init(mode: Mode, isSent: Binding<Bool>) {
        self.mode = mode
        _isCommentSent = isSent
        switch mode {
        case let .editGround(info), let .editEvent(info):
            oldCommentText = info.oldComment
        default: break
        }
    }

    var body: some View {
        content
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: dismissErrorAlert) { TextOk() }
        }
        .onChange(of: viewModel.isSuccess, perform: dismiss)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onAppear(perform: setupOldCommentIfNeeded)
        .onDisappear(perform: cancelTasks)
        .navigationTitle("Комментарий")
    }
}

extension CommentView {
    enum Mode {
        case newForGround(id: Int)
        case newForEvent(id: Int)
        case editGround(EditInfo)
        case editEvent(EditInfo)

        struct EditInfo {
            let objectID, commentID: Int
            let oldComment: String
        }
    }
}

private extension CommentView {
    var content: some View {
        SendMessageView(
            text: $commentText,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: isSendButtonDisabled,
            sendAction: sendAction,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: dismissErrorAlert
        )
    }

    func sendAction() {
        switch mode {
        case .newForGround, .newForEvent:
            addCommentTask = Task {
                await viewModel.addComment(
                    mode,
                    comment: commentText,
                    defaults: defaults
                )
            }
        case .editGround, .editEvent:
            editCommentTask = Task {
                await viewModel.editComment(
                    for: mode,
                    newComment: commentText,
                    with: defaults
                )
            }
        }
        isFocused.toggle()
    }

    func dismiss(isSuccess: Bool) {
        isCommentSent.toggle()
        dismiss()
    }

    func dismissErrorAlert() {
        viewModel.closedErrorAlert()
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isFocused.toggle()
        }
    }

    func setupOldCommentIfNeeded() {
        if let oldComment = oldCommentText {
            commentText = oldComment
        }
    }

    var isSendButtonDisabled: Bool {
        switch mode {
        case .newForGround, .newForEvent:
            return commentText.isEmpty || viewModel.isLoading
        case .editGround, .editEvent:
            return commentText == oldCommentText || viewModel.isLoading
        }
    }

    func cancelTasks() {
        [addCommentTask, editCommentTask].forEach { $0?.cancel() }
    }
}

struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(mode: .newForGround(id: .zero), isSent: .constant(false))
            .environmentObject(DefaultsService())
    }
}

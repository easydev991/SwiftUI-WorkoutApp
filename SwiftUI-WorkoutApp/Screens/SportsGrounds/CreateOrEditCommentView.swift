//
//  CreateOrEditCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.04.2022.
//

import SwiftUI

struct CreateOrEditCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = CreateOrEditCommentViewModel()
    @State private var commentText = ""
    @State private var isCommentSent = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var addCommentTask: Task<Void, Never>?
    @State private var editCommentTask: Task<Void, Never>?
    @FocusState private var isFocused

    private let mode: Mode
    private var oldCommentText: String?

    init(mode: Mode) {
        self.mode = mode
        if case let .edit(_, _, oldComment) = mode {
            oldCommentText = oldComment
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                topHStack
                textView
                Spacer()
            }
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .disabled(viewModel.isLoading)
        .padding()
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: dismissErrorAlert) { TextOk() }
        }
        .onChange(of: viewModel.isSuccess, perform: toggleSuccessAlert)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onAppear(perform: setupOldCommentIfNeeded)
        .onDisappear(perform: cancelTasks)
        .navigationTitle("Комментарий")
    }
}

extension CreateOrEditCommentView {
    enum Mode {
        case create(groundID: Int)
        case edit(groundID: Int, commentID: Int, commentText: String)
    }
}

private extension CreateOrEditCommentView {
    var textView: some View {
        TextEditor(text: $commentText)
            .frame(height: 200)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .onAppear(perform: showKeyboard)
    }

    var topHStack: some View {
        HStack {
            Spacer()
            sendButton
        }
    }

    var sendButton: some View {
        Button {
            switch mode {
            case let .create(groundID):
                addCommentTask = Task {
                    await viewModel.addComment(
                        to: groundID,
                        comment: commentText,
                        defaults: defaults
                    )
                }
            case let .edit(groundID, commentID, _):
                editCommentTask = Task {
                    await viewModel.editComment(
                        for: groundID,
                        commentID: commentID,
                        newComment: commentText,
                        with: defaults
                    )
                }
            }
            isFocused.toggle()
        } label: {
            Label("Отправить", systemImage: "paperplane.fill")
        }
        .tint(.blue)
        .buttonStyle(.borderedProminent)
        .disabled(isSendButtonDisabled)
        .alert(Constants.Alert.success, isPresented: $isCommentSent) {
            Button { dismiss() } label: { TextOk() }
        }
    }

    func toggleSuccessAlert(isSuccess: Bool) {
        isCommentSent = isSuccess
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
        case .create: return commentText.isEmpty
        case .edit: return commentText == oldCommentText
        }
    }

    func cancelTasks() {
        [addCommentTask, editCommentTask].forEach { $0?.cancel() }
    }
}

struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateOrEditCommentView(mode: .create(groundID: .zero))
            .environmentObject(UserDefaultsService())
    }
}

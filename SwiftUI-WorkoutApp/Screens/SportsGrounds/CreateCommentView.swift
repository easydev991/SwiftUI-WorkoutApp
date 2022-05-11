//
//  CreateCommentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 23.04.2022.
//

import SwiftUI

struct CreateCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = CreateCommentViewModel()
    @State private var isCommentSent = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @FocusState private var isFocused

    let groundID: Int
    var body: some View {
        ZStack {
            VStack {
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
        .toolbar { sendButton }
        .navigationTitle("Комментарий")
    }
}

private extension CreateCommentView {
    var textView: some View {
        TextEditor(text: $viewModel.commentText)
            .frame(height: 200)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .onAppear(perform: showKeyboard)
    }

    var sendButton: some View {
        Button {
            Task { await viewModel.addComment(to: groundID, defaults: defaults) }
            isFocused.toggle()
        } label: {
            Text("Отправить")
        }
        .disabled(viewModel.commentText.isEmpty)
        .alert(Constants.Alert.commentSent, isPresented: $isCommentSent) {
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
}

struct CreateCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CreateCommentView(groundID: .zero)
    }
}

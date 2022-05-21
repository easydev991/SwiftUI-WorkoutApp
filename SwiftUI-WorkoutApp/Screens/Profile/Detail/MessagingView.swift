//
//  MessagingView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import SwiftUI

struct MessagingView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = MessagingViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @Binding private var message: String
    @Binding private var isActive: Bool
    @FocusState private var isFocused
    @State private var sendMessageTask: Task<Void, Never>?
    private let userID: Int

    init(
        with userID: Int,
        message: Binding<String>,
        isActive: Binding<Bool>
    ) {
        self.userID = userID
        self._message = message
        self._isActive = isActive
    }

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                sendButtonStack
                textView
                Spacer()
            }
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .padding()
        .onChange(of: viewModel.isSuccess, perform: dismiss)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .onDisappear(perform: cancelTask)
    }
}

private extension MessagingView {
    var sendButtonStack: some View {
        HStack {
            Spacer()
            Button(action: sendMessage) {
                Label("Отправить", systemImage: "paperplane.fill")
            }
            .tint(.blue)
            .buttonStyle(.borderedProminent)
            .disabled(message.isEmpty || viewModel.isLoading)
        }
    }

    var textView: some View {
        TextEditor(text: $message)
            .frame(height: 200)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
            .focused($isFocused)
            .onAppear(perform: showKeyboard)
    }

    func sendMessage() {
        sendMessageTask = Task {
            await viewModel.send(message, to: userID, with: defaults)
        }
    }

    func showKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isFocused.toggle()
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func dismiss(isSuccess: Bool) {
        message = ""
        isActive.toggle()
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTask() {
        sendMessageTask?.cancel()
    }
}

struct MessagingView_Previews: PreviewProvider {
    static var previews: some View {
        MessagingView(with: .zero, message: .constant(""), isActive: .constant(true))
    }
}

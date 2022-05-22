//
//  DialogView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import SwiftUI

struct DialogView: View {
    @EnvironmentObject private var network: CheckNetworkService
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogViewModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @Namespace private var chatScrollView

    @Binding var dialog: DialogResponse

    var body: some View {
        ScrollViewReader { scrollView in
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.list) { message in
                            ChatBubble(messageType(for: message)) {
                                chatCell(for: message)
                            }
                        }
                    }
                    .id(chatScrollView)
                    .onChange(of: viewModel.list) { _ in
                        withAnimation {
                            scrollView.scrollTo(chatScrollView, anchor: .bottom)
                        }
                    }
                }
                HStack {
                    newMessageTextField
                    sendMessageButton
                }
                .padding()
            }
        }
        .onChange(of: viewModel.markedAsRead, perform: updateDialogUnreadCount)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .task { await markAsRead() }
        .task { await viewModel.makeItems(for: dialog.id, with: defaults) }
        .onDisappear(perform: cancelTasks)
        .toolbar { linkToAnotherUser }
        .navigationTitle(dialog.anotherUserName.valueOrEmpty)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension DialogView {
    var linkToAnotherUser: some View {
        NavigationLink {
            UserDetailsView(userID: dialog.anotherUserID.valueOrZero)
        } label: {
            CacheImageView(
                url: dialog.anotherUserImageURL,
                mode: .user
            )
        }
        .disabled(viewModel.isLoading)
    }

    func chatCell(for message: MessageResponse) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(message.formattedMessage)
                .padding(.top, 12)
                .padding(.horizontal, 20)
            Text(message.messageDateString)
                .font(.caption2)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
                .opacity(0.75)
        }
        .foregroundColor(.white)
        .background(Color(uiColor: messageType(for: message).color))
    }

    var newMessageTextField: some View {
        TextEditor(text: $viewModel.newMessage)
            .frame(maxHeight: 40)
            .padding(.horizontal, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.5), lineWidth: 1)
            )
    }

    var sendMessageButton: some View {
        Button(action: sendMessage) {
            Image(systemName: "paperplane.fill")
                .font(.title)
                .tint(.blue)
        }
        .disabled(isSendButtonDisabled)
    }

    var isSendButtonDisabled: Bool {
        viewModel.newMessage.isEmpty
        || viewModel.isLoading
        || !network.isConnected
    }

    func updateDialogUnreadCount(isRead: Bool) {
        if isRead { dialog.unreadMessagesCount = .zero }
    }

    func markAsRead() async {
        if dialog.unreadMessagesCount > .zero {
            await viewModel.markAsRead(from: dialog.anotherUserID.valueOrZero, with: defaults)
        }
    }

    func sendMessage() {
        sendMessageTask = Task {
            await viewModel.sendMessage(in: dialog.id, to: dialog.anotherUserID.valueOrZero, with: defaults)
        }
    }

    func messageType(for message: MessageResponse) -> Constants.MessageType {
        message.userID == defaults.mainUserID
        ? .sent
        : .incoming
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        sendMessageTask?.cancel()
    }
}

struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(dialog: .constant(.mock))
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}

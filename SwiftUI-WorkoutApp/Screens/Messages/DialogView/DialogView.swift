import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Экран с диалогом
struct DialogView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = DialogViewModel()
    @State private var openAnotherUserProfile = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var refreshDialogTask: Task<Void, Never>?
    @Namespace private var chatScrollView
    @FocusState private var isMessageBarFocused: Bool
    let dialog: DialogResponse
    let markedAsReadClbk: () -> Void

    var body: some View {
        ScrollViewReader { scrollView in
            VStack {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(viewModel.list) { message in
                            ChatBubbleRowView(
                                messageType: message.userID == defaults.mainUserInfo?.userID
                                    ? .sent
                                    : .incoming,
                                message: message.formattedMessage,
                                messageTime: message.messageDateString
                            )
                        }
                    }
                    .padding(.horizontal)
                    .id(chatScrollView)
                    .onChange(of: viewModel.list) { _ in
                        withAnimation {
                            scrollView.scrollTo(chatScrollView, anchor: .bottom)
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        #warning("В iOS 16 заменить на .scrollDismissesKeyboard(.interactively)")
                        isMessageBarFocused = false
                    }
                )
                sendMessageBar
            }
        }
        .background(Color.swBackground)
        .onChange(of: viewModel.markedAsRead, perform: updateDialogUnreadCount)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .task(priority: .low) { await markAsRead() }
        .task(priority: .high) { await askForMessages() }
        .onDisappear(perform: cancelTasks)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                anotherUserProfileButton
            }
        }
        .navigationTitle(dialog.anotherUserName.valueOrEmpty)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension DialogView {
    var refreshButton: some View {
        Button {
            refreshDialogTask = Task {
                await askForMessages(refresh: true)
            }
        } label: {
            Image(systemName: Icons.Regular.refresh.rawValue)
        }
        .disabled(isToolbarItemDisabled)
    }

    var anotherUserProfileButton: some View {
        NavigationLink(
            isActive: $openAnotherUserProfile,
            destination: {
                UserDetailsView(from: dialog)
            },
            label: {
                CachedImage(
                    url: dialog.anotherUserImageURL,
                    mode: .avatarInDialogView,
                    didTapImage: { _ in
                        openAnotherUserProfile.toggle()
                    }
                )
                .borderedClipshape()
            }
        )
        .disabled(isToolbarItemDisabled)
    }

    var isToolbarItemDisabled: Bool {
        viewModel.isLoading || !network.isConnected
    }

    var sendMessageBar: some View {
        HStack(spacing: 10) {
            newMessageTextField
                .focused($isMessageBarFocused)
                .frame(height: 42)
                .padding(.horizontal, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isMessageBarFocused ? Color.swAccent : Color.swSeparators,
                            lineWidth: 0.5
                        )
                )
                .background(Color.swBackground)
                .animation(.default, value: isMessageBarFocused)
            SendChatMessageButton(action: sendMessage)
                .disabled(isSendButtonDisabled)
        }
        .padding()
    }

    @ViewBuilder
    var newMessageTextField: some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: $viewModel.newMessage)
                .tint(.swAccent)
                .scrollContentBackground(.hidden)
        } else {
            TextEditor(text: $viewModel.newMessage)
                .accentColor(.swAccent)
        }
    }

    var isSendButtonDisabled: Bool {
        viewModel.newMessage.isEmpty
            || viewModel.isLoading
            || !network.isConnected
    }

    func updateDialogUnreadCount(isRead: Bool) {
        if isRead { markedAsReadClbk() }
    }

    func markAsRead() async {
        if dialog.unreadMessagesCount > .zero {
            await viewModel.markAsRead(from: dialog.anotherUserID.valueOrZero, with: defaults)
        }
    }

    func askForMessages(refresh: Bool = false) async {
        await viewModel.makeItems(for: dialog.id, refresh: refresh, with: defaults)
    }

    func sendMessage() {
        sendMessageTask = Task(priority: .userInitiated) {
            await viewModel.sendMessage(in: dialog.id, to: dialog.anotherUserID.valueOrZero, with: defaults)
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    func cancelTasks() {
        [refreshDialogTask, sendMessageTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct DialogView_Previews: PreviewProvider {
    static var previews: some View {
        DialogView(dialog: .preview, markedAsReadClbk: {})
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif

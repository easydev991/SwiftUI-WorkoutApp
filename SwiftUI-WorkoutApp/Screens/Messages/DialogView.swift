import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с диалогом
struct DialogView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var messages = [MessageResponse]()
    @State private var newMessage = ""
    @State private var isLoading = false
    /// `NavigationLink` не работает сам по себе внутри тулбара,
    /// т.к. тулбар не находится в иерархии `NavigationView`
    @State private var openAnotherUserProfile = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var refreshDialogTask: Task<Void, Never>?
    @Namespace private var chatScrollView
    @FocusState private var isMessageBarFocused: Bool
    let dialog: DialogResponse
    let markedAsReadClbk: (DialogResponse) -> Void

    var body: some View {
        ScrollViewReader { scrollView in
            VStack {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(messages) { message in
                            ChatBubbleRowView(
                                messageType: message.userID == defaults.mainUserInfo?.id
                                    ? .sent
                                    : .incoming,
                                message: message.formattedMessage,
                                messageTime: message.messageDateString
                            )
                        }
                    }
                    .padding(.horizontal)
                    .id(chatScrollView)
                    .onChange(of: messages) { _ in
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
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok") { errorTitle = "" }
        }
        .task(priority: .low) { await markAsRead() }
        .task(priority: .high) { await askForMessages() }
        .onDisappear {
            [refreshDialogTask, sendMessageTask].forEach { $0?.cancel() }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                anotherUserProfileButton
            }
        }
        .navigationTitle(dialog.anotherUserName ?? "")
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
            Icons.Regular.refresh.view
        }
        .disabled(isToolbarItemDisabled)
    }

    var anotherUserProfileButton: some View {
        NavigationLink(
            isActive: $openAnotherUserProfile,
            destination: { UserDetailsView(from: dialog) },
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
        isLoading || !network.isConnected
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
            TextEditor(text: $newMessage)
                .tint(.swAccent)
                .scrollContentBackground(.hidden)
        } else {
            TextEditor(text: $newMessage)
                .accentColor(.swAccent)
        }
    }

    var isSendButtonDisabled: Bool {
        newMessage.isEmpty
            || isLoading
            || !network.isConnected
    }

    func markAsRead() async {
        guard dialog.hasUnreadMessages else { return }
        do {
            let userID = dialog.anotherUserID ?? 0
            if try await SWClient(with: defaults).markAsRead(from: userID) {
                markedAsReadClbk(dialog)
            }
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
    }

    func askForMessages(refresh: Bool = false) async {
        if isLoading, !refresh { return }
        if !refresh { isLoading = true }
        do {
            messages = try await SWClient(with: defaults).getMessages(for: dialog.id).reversed()
        } catch {
            setupErrorAlert(ErrorFilter.message(from: error))
        }
        isLoading = false
    }

    func sendMessage() {
        isLoading = true
        sendMessageTask = Task(priority: .userInitiated) {
            do {
                let userID = dialog.anotherUserID ?? 0
                if try await SWClient(with: defaults).sendMessage(newMessage, to: userID) {
                    newMessage = ""
                    await askForMessages(refresh: true)
                }
            } catch {
                setupErrorAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(_ message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }
}

#if DEBUG
#Preview {
    DialogView(dialog: .preview, markedAsReadClbk: { _ in })
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif

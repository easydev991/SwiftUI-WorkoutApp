import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран для отдельного диалога
struct DialogScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var messages = [MessageResponse]()
    @State private var newMessage = ""
    @State private var isLoading = false
    /// `NavigationLink` не работает сам по себе внутри тулбара,
    /// т.к. тулбар не находится в иерархии `NavigationView`
    @State private var openAnotherUserProfile = false
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var refreshDialogTask: Task<Void, Never>?
    @FocusState private var isMessageBarFocused: Bool
    let dialog: DialogResponse
    let markedAsReadClbk: (DialogResponse) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                makeScrollView(with: proxy)
                    .scrollDismissesKeyboard(.interactively)
                sendMessageBar
            }
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .task {
            async let markAsReadTask: () = markAsRead()
            async let askForMessagesTask: () = askForMessages()
            _ = await (markAsReadTask, askForMessagesTask)
        }
        .onDisappear { refreshDialogTask?.cancel() }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                refreshButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                anotherUserProfileButton
            }
        }
        .navigationTitle(dialog.anotherUserName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $openAnotherUserProfile) {
            UserDetailsScreen(from: dialog)
        }
    }
}

private extension DialogScreen {
    var refreshButton: some View {
        Button {
            refreshDialogTask = Task {
                await askForMessages(refresh: true)
            }
        } label: {
            Icons.Regular.refresh.view
        }
        .tint(.accent)
        .disabled(isLoading)
    }

    var anotherUserProfileButton: some View {
        CachedImage(
            url: dialog.anotherUserImageURL,
            mode: .avatarInDialogView,
            didTapImage: { _ in
                openAnotherUserProfile.toggle()
            }
        )
        .borderedCircleClipShape()
        .disabled(isLoading)
    }

    func makeScrollView(with proxy: ScrollViewProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(messages) { message in
                    ChatBubbleRowView(
                        messageType: message.userId == defaults.mainUserInfo?.id
                            ? .sent
                            : .incoming,
                        message: message.formattedMessage,
                        messageTime: message.messageDateString
                    )
                }
            }
            .padding(.horizontal)
            .task(id: messages.count) {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if let lastMessageId = messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastMessageId, anchor: .bottom)
                    }
                }
            }
        }
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
            SendChatMessageButton {
                sendMessage()
            }
            .disabled(isSendButtonDisabled)
        }
        .padding()
    }

    var newMessageTextField: some View {
        TextEditor(text: $newMessage)
            .tint(.swAccent)
            .scrollContentBackground(.hidden)
    }

    var isSendButtonDisabled: Bool {
        newMessage.isEmpty || isLoading
    }

    func markAsRead() async {
        guard dialog.hasUnreadMessages else { return }
        do {
            let userId = dialog.anotherUserId ?? 0
            try await SWClient(with: defaults).markAsRead(from: userId)
            markedAsReadClbk(dialog)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func askForMessages(refresh: Bool = false) async {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        if isLoading, !refresh { return }
        if !refresh { isLoading = true }
        do {
            messages = try await SWClient(with: defaults).getMessages(for: dialog.id).reversed()
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }

    func sendMessage() {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        isMessageBarFocused = false
        sendMessageTask = Task(priority: .userInitiated) {
            do {
                let userId = dialog.anotherUserId ?? 0
                try await SWClient(with: defaults).sendMessage(newMessage, to: userId)
                newMessage = ""
                await askForMessages(refresh: true)
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }
}

#if DEBUG
#Preview {
    DialogScreen(dialog: .preview, markedAsReadClbk: { _ in })
        .environmentObject(DefaultsService())
}
#endif

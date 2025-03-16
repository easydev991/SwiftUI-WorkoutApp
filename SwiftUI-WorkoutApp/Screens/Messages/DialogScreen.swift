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
    @Namespace private var chatScrollView
    @FocusState private var isMessageBarFocused: Bool
    let dialog: DialogResponse
    let markedAsReadClbk: (DialogResponse) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                if #available(iOS 16, *) {
                    makeScrollView(with: proxy)
                        .scrollDismissesKeyboard(.interactively)
                } else {
                    makeScrollView(with: proxy)
                        .simultaneousGesture(
                            DragGesture().onChanged { _ in
                                isMessageBarFocused = false
                            }
                        )
                }
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
        .disabled(isToolbarItemDisabled)
    }

    var anotherUserProfileButton: some View {
        NavigationLink(
            isActive: $openAnotherUserProfile,
            destination: { UserDetailsScreen(from: dialog) },
            label: {
                CachedImage(
                    url: dialog.anotherUserImageURL,
                    mode: .avatarInDialogView,
                    didTapImage: { _ in
                        openAnotherUserProfile.toggle()
                    }
                )
                .borderedCircleClipShape()
            }
        )
        .disabled(isToolbarItemDisabled)
    }

    var isToolbarItemDisabled: Bool {
        isLoading || !isNetworkConnected
    }

    func makeScrollView(with proxy: ScrollViewProxy) -> some View {
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
                    proxy.scrollTo(chatScrollView, anchor: .bottom)
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
            SendChatMessageButton { sendMessage() }
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
            || !isNetworkConnected
    }

    func markAsRead() async {
        guard dialog.hasUnreadMessages else { return }
        do {
            let userID = dialog.anotherUserID ?? 0
            if try await SWClient(with: defaults).markAsRead(from: userID) {
                markedAsReadClbk(dialog)
            }
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func askForMessages(refresh: Bool = false) async {
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
        isLoading = true
        isMessageBarFocused = false
        sendMessageTask = Task(priority: .userInitiated) {
            do {
                let userID = dialog.anotherUserID ?? 0
                if try await SWClient(with: defaults).sendMessage(newMessage, to: userID) {
                    newMessage = ""
                    await askForMessages(refresh: true)
                }
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

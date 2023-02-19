import NetworkStatus
import SwiftUI
import SWModels

/// Экран со списком пользователей
struct UsersListView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = UsersListViewModel()
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var messageRecipient: UserModel?
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var sendMessageTask: Task<Void, Never>?
    let mode: Mode

    var body: some View {
        Form {
            if !viewModel.friendRequests.isEmpty {
                friendRequestsSection
            }
            List(viewModel.users, id: \.self) { model in
                listItem(for: model)
                    .disabled(model.id == defaults.mainUserInfo?.userID)
            }
        }
        .sheet(
            item: $messageRecipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .disabled(viewModel.isLoading || !network.isConnected)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: messagingViewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: messagingViewModel.isMessageSent, perform: endMessaging)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .onDisappear(perform: cancelTask)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension UsersListView {
    enum Mode {
        /// Друзья пользователя с указанным `id`
        ///
        /// При нажатии на друга откроется его профиль
        case friends(userID: Int)
        /// Друзья пользователя с указанным `id` для чата
        ///
        /// При нажатии на друга откроется окно отправки сообщения
        case friendsForChat(userID: Int)
        /// Участники мероприятия
        case eventParticipants(list: [UserResponse])
        /// Тренирующиеся на площадке
        case groundParticipants(list: [UserResponse])
        /// Черный список основного пользователя
        case blacklist
    }
}

private extension UsersListView.Mode {
    var title: String {
        switch self {
        case .friends, .friendsForChat:
            return "Друзья"
        case .eventParticipants:
            return "Участники мероприятия"
        case .groundParticipants:
            return "Здесь тренируются"
        case .blacklist:
            return "Черный список"
        }
    }
}

private extension UsersListView {
    var friendRequestsSection: some View {
        Section {
            NavigationLink {
                FriendRequestsView(viewModel: viewModel)
            } label: {
                HStack {
                    Label("Заявки", systemImage: "person.fill.badge.plus")
                    Spacer()
                    Text(viewModel.friendRequests.count.description)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    func listItem(for model: UserModel) -> some View {
        switch mode {
        case .friendsForChat:
            Button {
                messageRecipient = model
            } label: {
                UserViewCell(model: model)
            }
        case .friends, .eventParticipants, .groundParticipants, .blacklist:
            NavigationLink {
                UserDetailsView(from: model)
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                UserViewCell(model: model)
            }
        }
    }

    func messageSheet(for recipient: UserModel) -> some View {
        SendMessageView(
            header: "Сообщение для \(recipient.name)",
            text: $messagingViewModel.messageText,
            isLoading: messagingViewModel.isLoading,
            isSendButtonDisabled: !messagingViewModel.canSendMessage,
            sendAction: { sendMessage(to: recipient.id) },
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    func sendMessage(to userID: Int) {
        sendMessageTask = Task {
            await messagingViewModel.sendMessage(to: userID, with: defaults)
        }
    }

    func endMessaging(isSuccess: Bool = true) {
        if isSuccess {
            messagingViewModel.messageText = ""
            messageRecipient = nil
        }
    }

    func askForUsers(refresh: Bool = false) async {
        await viewModel.makeInfo(for: mode, refresh: refresh, with: defaults)
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
        messagingViewModel.clearErrorMessage()
    }

    func cancelTask() {
        sendMessageTask?.cancel()
    }
}

#if DEBUG
struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView(mode: .friends(userID: .previewUserID))
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif

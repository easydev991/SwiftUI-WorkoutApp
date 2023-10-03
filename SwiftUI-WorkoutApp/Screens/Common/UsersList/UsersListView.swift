import DesignSystem
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
        ScrollView {
            VStack(spacing: 0) {
                friendRequestsSectionIfNeeded
                SectionView(
                    header: viewModel.hasFriendRequests ? "Друзья" : nil,
                    mode: .regular
                ) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.users) { item in
                            listItem(for: item)
                                .disabled(item.id == defaults.mainUserInfo?.userID)
                        }
                    }
                }
                .padding(.top)
            }
            .padding(.horizontal)
        }
        .sheet(
            item: $messageRecipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .disabled(!network.isConnected)
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
    var title: LocalizedStringKey {
        switch self {
        case .friends, .friendsForChat:
            "Друзья"
        case .eventParticipants:
            "Участники мероприятия"
        case .groundParticipants:
            "Здесь тренируются"
        case .blacklist:
            "Черный список"
        }
    }
}

private extension UsersListView {
    @ViewBuilder
    var friendRequestsSectionIfNeeded: some View {
        if viewModel.hasFriendRequests {
            FriendRequestsView(viewModel: viewModel)
                .padding(.top)
        }
    }

    @ViewBuilder
    func listItem(for model: UserModel) -> some View {
        switch mode {
        case .friendsForChat:
            Button {
                messageRecipient = model
            } label: {
                userRowView(with: model)
            }
        case .friends, .eventParticipants, .groundParticipants, .blacklist:
            NavigationLink {
                UserDetailsView(from: model)
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                userRowView(with: model)
            }
        }
    }

    func userRowView(with model: UserModel) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.imageURL,
                    name: model.name,
                    address: model.shortAddress
                )
            )
        )
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
#Preview {
    UsersListView(mode: .friends(userID: .previewUserID))
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif

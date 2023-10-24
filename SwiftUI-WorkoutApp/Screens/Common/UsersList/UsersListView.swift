import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран со списком пользователей
struct UsersListView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var users = [UserModel]()
    @State private var friendRequests = [UserModel]()
    @State private var isLoading = false
    @State private var messagingModel = MessagingModel()
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var friendRequestTask: Task<Void, Never>?
    let mode: Mode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                friendRequestsSectionIfNeeded
                SectionView(
                    header: friendRequests.isEmpty ? nil : "Друзья",
                    mode: .regular
                ) {
                    LazyVStack(spacing: 12) {
                        ForEach(users) { item in
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
            item: $messagingModel.recipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .disabled(!network.isConnected)
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button("Ok", action: closeAlert)
        }
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .onDisappear { sendMessageTask?.cancel() }
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
        if !friendRequests.isEmpty {
            FriendRequestsView(
                friendRequests: friendRequests,
                action: respondToFriendRequest
            )
            .padding(.top)
        }
    }

    @ViewBuilder
    func listItem(for model: UserModel) -> some View {
        switch mode {
        case .friendsForChat:
            Button {
                messagingModel.recipient = model
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
            text: $messagingModel.message,
            isLoading: messagingModel.isLoading,
            isSendButtonDisabled: !messagingModel.canSendMessage,
            sendAction: { sendMessage(to: recipient.id) },
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    func sendMessage(to userID: Int) {
        messagingModel.isLoading = true
        sendMessageTask = Task {
            do {
                let isSuccess = try await SWClient(with: defaults).sendMessage(messagingModel.message, to: userID)
                endMessaging(isSuccess: isSuccess)
            } catch {
                setupErrorAlert(with: ErrorFilter.message(from: error))
            }
            messagingModel.isLoading = false
        }
    }

    func endMessaging(isSuccess: Bool = true) {
        if isSuccess {
            messagingModel.message = ""
            messagingModel.recipient = nil
        }
    }

    func askForUsers(refresh: Bool = false) async {
        do {
            if !users.isEmpty || isLoading, !refresh { return }
            switch mode {
            case let .friends(userID), let .friendsForChat(userID):
                if !refresh { isLoading = true }
                if userID == defaults.mainUserInfo?.userID {
                    if defaults.friendRequestsList.isEmpty || refresh {
                        try? await SWClient(with: defaults).getFriendRequests()
                    }
                    friendRequests = defaults.friendRequestsList.map(UserModel.init)
                }
                let friends = try await SWClient(with: defaults).getFriendsForUser(id: userID)
                users = friends.map(UserModel.init)
            case let .eventParticipants(list), let .groundParticipants(list):
                users = list.map(UserModel.init)
            case .blacklist:
                if !refresh { isLoading = true }
                if defaults.blacklistedUsers.isEmpty {
                    try await SWClient(with: defaults).getBlacklist()
                }
                users = defaults.blacklistedUsers.map(UserModel.init)
            }
        } catch {
            setupErrorAlert(with: ErrorFilter.message(from: error))
        }
        if !refresh { isLoading = false }
    }

    func respondToFriendRequest(from userID: Int, accept: Bool) {
        if isLoading { return }
        isLoading = true
        friendRequestTask = Task {
            do {
                if try await SWClient(with: defaults).respondToFriendRequest(from: userID, accept: accept) {
                    friendRequests = defaults.friendRequestsList.map(UserModel.init)
                    defaults.setUserNeedUpdate(true)
                }
            } catch {
                setupErrorAlert(with: ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() { errorTitle = "" }
}

#if DEBUG
#Preview {
    UsersListView(mode: .friends(userID: .previewUserID))
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif

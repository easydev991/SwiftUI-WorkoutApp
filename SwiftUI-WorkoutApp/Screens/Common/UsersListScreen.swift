import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком пользователей
struct UsersListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var users = [UserResponse]()
    @State private var friendRequests = [UserResponse]()
    @State private var isLoading = false
    @State private var messagingModel = MessagingModel()
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var friendRequestTask: Task<Void, Never>?
    private var client: SWClient { SWClient(with: defaults) }
    let mode: Mode

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                friendRequestsSectionIfNeeded
                friendsSectionIfNeeded
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
        .sheet(
            item: $messagingModel.recipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .disabled(!isNetworkConnected)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .onDisappear { sendMessageTask?.cancel() }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension UsersListScreen {
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
        case parkParticipants(list: [UserResponse])
        /// Черный список основного пользователя
        case blacklist
    }
}

private extension UsersListScreen.Mode {
    var title: LocalizedStringKey {
        switch self {
        case .friends, .friendsForChat:
            "Друзья"
        case .eventParticipants:
            "Участники мероприятия"
        case .parkParticipants:
            "Здесь тренируются"
        case .blacklist:
            "Черный список"
        }
    }
}

private extension UsersListScreen {
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
    var friendsSectionIfNeeded: some View {
        ZStack {
            if !users.isEmpty {
                SectionView(
                    header: friendRequests.isEmpty ? nil : "Друзья",
                    mode: .regular
                ) {
                    LazyVStack(spacing: 12) {
                        ForEach(users) { item in
                            listItem(for: item)
                                .disabled(item.id == defaults.mainUserInfo?.id)
                        }
                    }
                }
            }
        }
        .animation(.default, value: users)
        .padding(.top)
    }

    @ViewBuilder
    func listItem(for model: UserResponse) -> some View {
        switch mode {
        case .friendsForChat:
            Button {
                messagingModel.recipient = model
            } label: {
                userRowView(with: model)
            }
        case .friends, .eventParticipants, .parkParticipants, .blacklist:
            NavigationLink {
                UserDetailsScreen(for: model)
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                userRowView(with: model)
            }
        }
    }

    func userRowView(with model: UserResponse) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.avatarURL,
                    name: model.userName ?? "",
                    address: SWAddress(model.countryID, model.cityID)?.address ?? ""
                )
            )
        )
    }

    func messageSheet(for recipient: UserResponse) -> some View {
        SendMessageScreen(
            header: .init(recipient.messageFor),
            text: $messagingModel.message,
            isLoading: messagingModel.isLoading,
            isSendButtonDisabled: !messagingModel.canSendMessage,
            sendAction: { sendMessage(to: recipient.id) }
        )
    }

    func sendMessage(to userID: Int) {
        messagingModel.isLoading = true
        sendMessageTask = Task {
            do {
                let isSuccess = try await client.sendMessage(messagingModel.message, to: userID)
                endMessaging(isSuccess: isSuccess)
            } catch {
                SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
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
        guard !isLoading else { return }
        do {
            switch mode {
            case let .friends(userID), let .friendsForChat(userID):
                if !users.isEmpty, !refresh { return }
                if !refresh { isLoading = true }
                if userID == defaults.mainUserInfo?.id {
                    try await makeListForMainUser(userID)
                } else {
                    users = try await client.getFriendsForUser(id: userID)
                }
            case let .eventParticipants(list), let .parkParticipants(list):
                users = list
            case .blacklist:
                if !users.isEmpty, !refresh { return }
                if !refresh { isLoading = true }
                users = try await client.getBlacklist()
                try? defaults.saveBlacklist(users)
                if users.isEmpty {
                    dismiss()
                }
            }
        } catch {
            SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
        }
        isLoading = false
    }

    func respondToFriendRequest(from userID: Int, accept: Bool) {
        isLoading = true
        friendRequestTask = Task {
            do {
                let isSuccess = try await client.respondToFriendRequest(from: userID, accept: accept)
                if isSuccess {
                    friendRequests.removeAll(where: { $0.id == userID })
                    try await makeListForMainUser(defaults.mainUserInfo?.id)
                }
            } catch {
                SWAlert.shared.presentDefaultUIKit(message: error.localizedDescription)
            }
            isLoading = false
        }
    }

    func makeListForMainUser(_ id: Int?) async throws {
        guard let id else { return }
        async let friendsTask = client.getFriendsForUser(id: id)
        async let requestsTask = client.getFriendRequests()
        let (friends, requests) = try await (friendsTask, requestsTask)
        try? defaults.saveFriendsIds(friends.map(\.id))
        try? defaults.saveFriendRequests(requests)
        users = friends
        friendRequests = requests
    }
}

#if DEBUG
#Preview {
    UsersListScreen(mode: .friends(userID: .previewUserID))
        .environmentObject(DefaultsService())
}
#endif

import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком друзей
struct FriendsListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @State private var friends = [UserResponse]()
    @State private var isLoading = false
    @State private var messagingModel = MessagingModel()
    @State private var sendMessageTask: Task<Void, Never>?
    private var client: SWClient { SWClient(with: defaults) }
    let mode: Mode

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(friends) { user in
                    listItem(for: user)
                        .disabled(user.id == defaults.mainUserInfo?.id)
                }
            }
            .animation(.default, value: friends)
            .padding()
        }
        .sheet(
            item: $messagingModel.recipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationTitle("Друзья")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension FriendsListScreen {
    enum Mode {
        /// Друзья пользователя с указанным `id`
        ///
        /// При нажатии на друга откроется его профиль
        case user(id: Int)
        /// Друзья пользователя с указанным `id` для чата
        ///
        /// При нажатии на друга откроется окно отправки сообщения
        case chat(userID: Int)
    }
}

private extension FriendsListScreen {
    @ViewBuilder
    func listItem(for model: UserResponse) -> some View {
        switch mode {
        case .chat:
            Button {
                messagingModel.recipient = model
            } label: {
                userRowView(with: model)
            }
        case .user:
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
                SWAlert.shared.presentDefaultUIKit(error)
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
            case let .user(id), let .chat(id):
                if !friends.isEmpty, !refresh { return }
                if !refresh { isLoading = true }
                friends = try await client.getFriendsForUser(id: id)
            }
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }
}

#if DEBUG
#Preview {
    FriendsListScreen(mode: .user(id: .previewUserID))
        .environmentObject(DefaultsService())
}
#endif

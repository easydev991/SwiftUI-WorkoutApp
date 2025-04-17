import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком друзей
struct FriendsListScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var currentState = CurrentState.initial
    @State private var messagingModel = MessagingModel()
    @State private var sendMessageTask: Task<Void, Never>?
    private var client: SWClient { SWClient(with: defaults) }
    let mode: Mode

    var body: some View {
        ScrollView {
            contentView
                .frame(maxWidth: .infinity)
                .animation(.default, value: currentState)
                .padding()
        }
        .sheet(
            item: $messagingModel.recipient,
            onDismiss: { endMessaging() },
            content: messageSheet
        )
        .loadingOverlay(if: currentState.isLoading)
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

        var userId: Int {
            switch self {
            case let .user(id), let .chat(id): id
            }
        }
    }
}

private extension FriendsListScreen {
    enum CurrentState: Equatable {
        case initial
        case loading
        case ready([UserResponse])
        case error(ErrorKind)

        var isLoading: Bool { self == .loading }
        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(friends): friends.isEmpty
            case .loading: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(friends): !friends.isEmpty
            default: false
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch currentState {
        case let .ready(friends):
            LazyVStack(spacing: 12) {
                ForEach(friends) { user in
                    listItem(for: user)
                        .disabled(user.id == defaults.mainUserInfo?.id)
                }
            }
        case let .error(errorKind):
            CommonErrorView(errorKind: errorKind)
        case .initial, .loading:
            ContainerRelativeView {
                Text("Загрузка...")
            }
        }
    }

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
                try await client.sendMessage(messagingModel.message, to: userID)
                endMessaging()
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
        guard currentState.shouldLoad || refresh else { return }
        guard isNetworkConnected else {
            if currentState.isReadyAndNotEmpty {
                SWAlert.shared.presentNoConnection(false)
            } else {
                currentState = .error(.notConnected)
            }
            return
        }
        if !refresh {
            // Иначе падает в CancellationError
            // Альтернативное решение: https://stackoverflow.com/a/76305308/11830041
            currentState = .loading
        }
        do {
            let friends = try await client.getFriendsForUser(id: mode.userId)
            currentState = .ready(friends)
        } catch {
            currentState = .error(.common(message: error.localizedDescription))
        }
    }
}

#if DEBUG
#Preview {
    FriendsListScreen(mode: .user(id: .previewUserID))
        .environmentObject(DefaultsService())
        .environment(\.isNetworkConnected, true)
}
#endif

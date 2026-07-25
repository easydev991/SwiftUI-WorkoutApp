import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с детальной информацией о пользователе
@MainActor
struct UserDetailsScreen: View {
    @Environment(\.analyticsService) private var analytics
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @EnvironmentObject private var dialogsViewModel: DialogsListScreen.ViewModel
    @State private var isLoading = false
    @State private var socialActions = SocialActions()
    @State private var messagingModel = MessagingModel()
    @State private var showBlacklistConfirmation = false
    @State private var friendActionTask: Task<Void, Never>?
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var blacklistUserTask: Task<Void, Never>?
    @State private var user: UserResponse

    init(for user: UserResponse?) {
        _user = .init(initialValue: user ?? .emptyValue)
    }

    init(from dialog: DialogResponse) {
        _user = .init(initialValue: .init(dialog: dialog))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileViews.makeUserInfo(for: user)
                communicationSection
                VStack(spacing: 12) {
                    ProfileViews.makeFriends(for: user)
                    ProfileViews.makeUsedParks(for: user)
                    ProfileViews.makeAddedParks(for: user)
                    ProfileViews.makeJournals(for: user)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                blockUserButton
            }
        }
        .onDisappear(perform: cancelTasks)
        .refreshable { await askForUserInfo(refresh: true) }
        .task { await askForUserInfo() }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .trackScreen(.profileOtherUser)
    }
}

private extension UserDetailsScreen {
    var communicationSection: some View {
        VStack(spacing: 12) {
            Button("Сообщение") { messagingModel.recipient = user }
                .buttonStyle(SWButtonStyle(icon: .message, mode: .filled, size: .large))
                .sheet(item: $messagingModel.recipient) { messageSheet(for: $0) }
            Button(socialActions.friend.description) { performFriendAction() }
                .buttonStyle(
                    SWButtonStyle(
                        icon: socialActions.friend == .remove
                            ? .deletePerson
                            : .addPerson,
                        mode: .tinted,
                        size: .large
                    )
                )
                .alert(.init(Strings.Alert.friendRequestSent), isPresented: $socialActions.isFriendRequestSent) {
                    Button("Ok") {}
                }
        }
        .padding(.bottom, 24)
        .disabled(socialActions.isBlacklisted)
    }

    var blockUserButton: some View {
        Button {
            showBlacklistConfirmation.toggle()
        } label: {
            Label(
                socialActions.blacklist.title,
                systemImage: Icons.Regular.exclamation.rawValue
            )
            .symbolVariant(socialActions.isBlacklisted ? .fill : .none)
        }
        .tint(.accent)
        .disabled(isLoading)
        .confirmationDialog(
            socialActions.blacklist.dialogTitle,
            isPresented: $showBlacklistConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                socialActions.blacklist.title,
                role: .destructive
            ) { performBlacklistAction() }
        } message: {
            Text(socialActions.blacklist.dialogMessage)
        }
    }

    func performFriendAction() {
        analytics.log(.userAction(action: socialActions.analyticsFriendAction))
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        friendActionTask = Task {
            do {
                #if DEBUG
                let client: FriendsClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: FriendsClient = SWClient(with: defaults.authHelper)
                #endif
                try await client.friendAction(userId: user.id, option: socialActions.friend)
                defaults.updateFriendIds(friendId: user.id, action: socialActions.friend)
                switch socialActions.friend {
                case .add:
                    socialActions.isFriendRequestSent = true
                case .remove:
                    socialActions.friend = .add
                }
                defaults.setUserNeedUpdate(true)
            } catch {
                analytics.log(.appError(kind: .friendRequestFailed, error: error))
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func performBlacklistAction() {
        analytics.log(.userAction(action: socialActions.analyticsBlacklistAction))
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        blacklistUserTask = Task {
            do {
                #if DEBUG
                let client: FriendsClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: FriendsClient = SWClient(with: defaults.authHelper)
                #endif
                try await client.blacklistAction(
                    user: user, option: socialActions.blacklist
                )
                defaults.updateBlacklist(option: socialActions.blacklist, user: user)
                SWAlert.shared.presentDefaultUIKit(
                    title: Strings.doneTitle,
                    message: socialActions.blacklist.result
                )
                switch socialActions.blacklist {
                case .add:
                    socialActions.blacklist = .remove
                case .remove:
                    socialActions.blacklist = .add
                }
            } catch {
                analytics.log(.appError(kind: .unblockFailed, error: error))
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        guard !isLoading else { return }
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else {
            return
        }
        if !refresh {
            isLoading = true
        }
        if refresh || !user.isFull {
            await makeUserInfo()
        }
        let isPersonInFriendList = defaults.friendsIdsList.contains(user.id)
        socialActions.friend = isPersonInFriendList ? .remove : .add
        let isPersonBlocked = defaults.blacklistedUsers.map(\.id).contains(user.id)
        socialActions.blacklist = isPersonBlocked ? .remove : .add
        isLoading = false
    }

    func messageSheet(for recipient: UserResponse) -> some View {
        SendMessageScreen(
            header: .init(recipient.messageFor),
            text: $messagingModel.message,
            isLoading: messagingModel.isLoading,
            isSendButtonDisabled: !messagingModel.canSendMessage,
            sendAction: sendMessage
        )
    }

    func makeUserInfo() async {
        do {
            #if DEBUG
            let client: ProfileClient = Constants.isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: defaults.authHelper)
            #else
            let client: ProfileClient = SWClient(with: defaults.authHelper)
            #endif
            user = try await client.getUserById(user.id)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func sendMessage() {
        analytics.log(.userAction(action: .sendMessage))
        messagingModel.isLoading = true
        sendMessageTask = Task {
            do {
                #if DEBUG
                let client: MessagesClient = Constants.isUITest
                    ? MockSWClient(instantResponse: true)
                    : SWClient(with: defaults.authHelper)
                #else
                let client: MessagesClient = SWClient(with: defaults.authHelper)
                #endif
                try await client.sendMessage(messagingModel.message, to: user.id)
                messagingModel.message = ""
                messagingModel.recipient = nil
                await dialogsViewModel.getDialogs(refresh: true, defaults: defaults)
            } catch {
                analytics.log(.appError(kind: .sendMessageFailed, error: error))
                SWAlert.shared.presentDefaultUIKit(error)
            }
            messagingModel.isLoading = false
        }
    }

    func cancelTasks() {
        [friendActionTask, sendMessageTask, blacklistUserTask].forEach { $0?.cancel() }
    }
}

private extension UserDetailsScreen {
    struct SocialActions {
        var friend = FriendAction.add
        var isFriendRequestSent = false
        var blacklist = BlacklistOption.add

        var analyticsFriendAction: AnalyticsEvent.UserAction {
            friend == .add ? .addFriend : .removeFriend
        }

        var analyticsBlacklistAction: AnalyticsEvent.UserAction {
            blacklist == .remove ? .unblockUser : .blockUser
        }

        var isBlacklisted: Bool {
            blacklist == .remove
        }
    }
}

#if DEBUG
#Preview {
    UserDetailsScreen(for: .preview)
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
        .environmentObject(DialogsListScreen.ViewModel(isUITest: true, authHelper: MockAuthHelper()))
        .networkStatus(true)
}
#endif

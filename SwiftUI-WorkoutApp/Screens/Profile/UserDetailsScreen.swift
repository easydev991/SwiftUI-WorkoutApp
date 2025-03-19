import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с детальной информацией о пользователе
@MainActor
struct UserDetailsScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
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
            ToolbarItem(placement: .topBarLeading) {
                refreshButtonIfNeeded
            }
            ToolbarItem(placement: .topBarTrailing) {
                blockUserButton
                    .disabled(isLoading)
            }
        }
        .onDisappear(perform: cancelTasks)
        .refreshable { await askForUserInfo(refresh: true) }
        .task { await askForUserInfo() }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension UserDetailsScreen {
    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button {
                Task { await askForUserInfo(refresh: true) }
            } label: {
                Icons.Regular.refresh.view
            }
            .disabled(isLoading)
        }
    }

    var communicationSection: some View {
        VStack(spacing: 12) {
            Button("Сообщение") { messagingModel.recipient = user }
                .buttonStyle(SWButtonStyle(icon: .message, mode: .filled, size: .large))
                .sheet(item: $messagingModel.recipient) { messageSheet(for: $0) }
            Button(.init(socialActions.friend.rawValue)) { performFriendAction() }
                .buttonStyle(
                    SWButtonStyle(
                        icon: socialActions.friend == .removeFriend
                            ? .deletePerson
                            : .addPerson,
                        mode: .tinted,
                        size: .large
                    )
                )
                .alert(.init(Constants.Alert.friendRequestSent), isPresented: $socialActions.isFriendRequestSent) {
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
                socialActions.blacklist.rawValue,
                systemImage: Icons.Regular.exclamation.rawValue
            )
            .symbolVariant(socialActions.isBlacklisted ? .fill : .none)
        }
        .confirmationDialog(
            .init(socialActions.blacklist.dialogTitle),
            isPresented: $showBlacklistConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                .init(socialActions.blacklist.rawValue),
                role: .destructive
            ) { performBlacklistAction() }
        } message: {
            Text(.init(socialActions.blacklist.dialogMessage))
        }
    }

    func performFriendAction() {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        friendActionTask = Task {
            do {
                let isSuccess = try await SWClient(with: defaults).friendAction(userID: user.id, option: socialActions.friend)
                if isSuccess {
                    defaults.updateFriendIds(friendID: user.id, action: socialActions.friend)
                    switch socialActions.friend {
                    case .sendFriendRequest:
                        socialActions.isFriendRequestSent = true
                    case .removeFriend:
                        socialActions.friend = .sendFriendRequest
                    }
                    defaults.setUserNeedUpdate(true)
                }
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func performBlacklistAction() {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        isLoading = true
        blacklistUserTask = Task {
            do {
                let isSuccess = try await SWClient(with: defaults).blacklistAction(
                    user: user, option: socialActions.blacklist
                )
                if isSuccess {
                    defaults.updateBlacklist(option: socialActions.blacklist, user: user)
                    switch socialActions.blacklist {
                    case .add:
                        SWAlert.shared.presentDefaultUIKit(
                            title: "Готово".localized,
                            message: "Пользователь добавлен в черный список".localized
                        )
                        socialActions.blacklist = .remove
                    case .remove:
                        SWAlert.shared.presentDefaultUIKit(
                            title: "Готово".localized,
                            message: "Пользователь удален из черного списка".localized
                        )
                        socialActions.blacklist = .add
                    }
                }
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        guard !isLoading else { return }
        if !refresh { isLoading = true }
        if refresh || !user.isFull {
            await makeUserInfo()
        }
        let isPersonInFriendList = defaults.friendsIdsList.contains(user.id)
        socialActions.friend = isPersonInFriendList ? .removeFriend : .sendFriendRequest
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
            user = try await SWClient(with: defaults).getUserByID(user.id)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }

    func sendMessage() {
        messagingModel.isLoading = true
        sendMessageTask = Task {
            do {
                if try await SWClient(with: defaults).sendMessage(messagingModel.message, to: user.id) {
                    messagingModel.message = ""
                    messagingModel.recipient = nil
                }
            } catch {
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
        var friend = FriendAction.sendFriendRequest
        var isFriendRequestSent = false
        var blacklist = BlacklistOption.add
        var isBlacklisted: Bool { blacklist == .remove }
    }
}

#if DEBUG
#Preview {
    UserDetailsScreen(for: .preview)
        .environmentObject(DefaultsService())
}
#endif

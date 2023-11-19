import NetworkStatus
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с детальной информацией профиля
@MainActor
struct UserDetailsView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var socialActions = SocialActions()
    @State private var messagingModel = MessagingModel()
    @State private var showAlertMessage = false
    @State private var showLogoutDialog = false
    @State private var showBlacklistConfirmation = false
    @State private var showSearchUsersScreen = false
    @State private var alertMessage = ""
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
                userInfoSection
                if isMainUser {
                    editProfileButton
                } else {
                    communicationSection
                }
                VStack(spacing: 12) {
                    friendsButtonIfNeeded
                    usesSportsGroundsIfNeeded
                    addedSportsGroundsIfNeeded
                    journalsButtonIfNeeded
                    if isMainUser { blacklistButtonIfNeeded }
                }
                if isMainUser { logoutButton }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .opacity(user.isFull ? 1 : 0)
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .alert(alertMessage, isPresented: $showAlertMessage) {
            Button("Ok", action: closeAlert)
        }
        .refreshable { await askForUserInfo(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButtonIfNeeded
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Group {
                    if isMainUser {
                        searchUsersButton
                    } else {
                        blockUserButton
                    }
                }
                .disabled(isLoading)
            }
        }
        .onDisappear(perform: cancelTasks)
        .task(priority: .userInitiated) { await askForUserInfo() }
        .navigationTitle("Профиль")
    }
}

private extension UserDetailsView {
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

    var userInfoSection: some View {
        ProfileView(
            imageURL: user.avatarURL,
            login: user.userName ?? "",
            genderWithAge: user.genderWithAge,
            countryAndCity: SWAddress(user.countryID, user.cityID)?.address ?? ""
        )
        .padding(24)
    }

    var editProfileButton: some View {
        NavigationLink(destination: EditAccountScreen()) {
            Text("Изменить профиль")
        }
        .buttonStyle(SWButtonStyle(icon: .pencil, mode: .tinted, size: .large))
        .padding(.bottom, 24)
    }

    var communicationSection: some View {
        VStack(spacing: 12) {
            Button("Сообщение") {
                messagingModel.recipient = user
            }
            .buttonStyle(SWButtonStyle(icon: .message, mode: .filled, size: .large))
            .sheet(item: $messagingModel.recipient, content: messageSheet)
            Button(.init(socialActions.friend.rawValue), action: performFriendAction)
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
                role: .destructive,
                action: performBlacklistAction
            )
        } message: {
            Text(.init(socialActions.blacklist.dialogMessage))
        }
    }

    func toggleFriendRequestSent(isSent: Bool) {
        socialActions.isFriendRequestSent = isSent
    }

    @ViewBuilder
    var usesSportsGroundsIfNeeded: some View {
        if user.hasUsedGrounds {
            NavigationLink {
                SportsGroundsListView(for: .usedBy(userID: user.id))
            } label: {
                FormRowView(
                    title: "Где тренируется",
                    trailingContent: .textWithChevron(user.usesSportsGroundsCountString)
                )
            }
            .accessibilityIdentifier("usesSportsGroundsButton")
        }
    }

    @ViewBuilder
    var addedSportsGroundsIfNeeded: some View {
        if user.hasAddedGrounds {
            NavigationLink {
                SportsGroundsListView(for: .added(list: user.addedSportsGrounds ?? []))
            } label: {
                FormRowView(
                    title: user.addedGroundsString,
                    trailingContent: .textWithChevron(user.addedSportsGroundsCountString)
                )
            }
        }
    }

    @ViewBuilder
    var friendsButtonIfNeeded: some View {
        let friendRequestsCount = defaults.friendRequestsList.count
        if user.hasFriends || (isMainUser && friendRequestsCount > .zero) {
            NavigationLink(destination: UsersListView(mode: .friends(userID: user.id))) {
                FormRowView(
                    title: "Друзья",
                    trailingContent: .textWithBadgeAndChevron(
                        user.friendsCountString,
                        friendRequestsCount
                    )
                )
            }
        }
    }

    @ViewBuilder
    var blacklistButtonIfNeeded: some View {
        if !defaults.blacklistedUsers.isEmpty {
            NavigationLink(destination: UsersListView(mode: .blacklist)) {
                FormRowView(
                    title: "Черный список",
                    trailingContent: .textWithChevron(defaults.blacklistedUsersCountString)
                )
            }
        }
    }

    @ViewBuilder
    var journalsButtonIfNeeded: some View {
        if isMainUser || user.hasJournals {
            NavigationLink {
                JournalsListView(userID: user.id)
                    .navigationTitle("Дневники")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                FormRowView(
                    title: "Дневники",
                    trailingContent: .textWithChevron(user.journalsCountString)
                )
            }
        }
    }

    @ViewBuilder
    var logoutButton: some View {
        Button("Выйти") { showLogoutDialog = true }
            .foregroundStyle(Color.swSmallElements)
            .padding(.top, 36)
            .padding(.bottom, 20)
            .confirmationDialog(
                .init(Constants.Alert.logout),
                isPresented: $showLogoutDialog,
                titleVisibility: .visible
            ) {
                Button("Выйти", role: .destructive) {
                    defaults.triggerLogout()
                }
            }
    }

    var searchUsersButton: some View {
        Button {
            showSearchUsersScreen = true
        } label: {
            Icons.Regular.magnifyingglass.view
        }
        .disabled(!network.isConnected)
        .accessibilityIdentifier("searchUsersButton")
        .sheet(isPresented: $showSearchUsersScreen) {
            NavigationView {
                SearchUsersView()
            }
        }
    }

    var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Icons.Regular.gearshape.view
        }
    }

    func performFriendAction() {
        isLoading = true
        friendActionTask = Task {
            do {
                if try await SWClient(with: defaults).friendAction(userID: user.id, option: socialActions.friend) {
                    switch socialActions.friend {
                    case .sendFriendRequest:
                        socialActions.isFriendRequestSent = true
                    case .removeFriend:
                        socialActions.friend = .sendFriendRequest
                    }
                }
            } catch {
                setupResponseAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func performBlacklistAction() {
        isLoading = true
        blacklistUserTask = Task {
            do {
                if try await SWClient(with: defaults).blacklistAction(
                    user: user, option: socialActions.blacklist
                ) {
                    switch socialActions.blacklist {
                    case .add:
                        setupResponseAlert("Пользователь добавлен в черный список")
                        socialActions.blacklist = .remove
                    case .remove:
                        setupResponseAlert("Пользователь удален из черного списка")
                        socialActions.blacklist = .add
                    }
                }
            } catch {
                setupResponseAlert(ErrorFilter.message(from: error))
            }
            isLoading = false
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        guard !isLoading else { return }
        if !refresh { isLoading = true }
        if isMainUser {
            if !refresh, !defaults.needUpdateUser,
               let mainUserInfo = defaults.mainUserInfo {
                user = mainUserInfo
            } else {
                await makeUserInfo()
            }
        } else {
            if !refresh, user.isFull {
                isLoading = false
            } else {
                await makeUserInfo()
            }
            let isPersonInFriendList = defaults.friendsIdsList.contains(user.id)
            socialActions.friend = isPersonInFriendList ? .removeFriend : .sendFriendRequest
            let isPersonBlocked = defaults.blacklistedUsers.map(\.id).contains(user.id)
            socialActions.blacklist = isPersonBlocked ? .remove : .add
        }
        isLoading = false
    }

    func messageSheet(for recipient: UserResponse) -> some View {
        SendMessageView(
            header: .init(recipient.messageFor),
            text: $messagingModel.message,
            isLoading: messagingModel.isLoading,
            isSendButtonDisabled: !messagingModel.canSendMessage,
            sendAction: sendMessage,
            showErrorAlert: $showAlertMessage,
            errorTitle: $alertMessage,
            dismissError: closeAlert
        )
    }

    func makeUserInfo() async {
        do {
            let client = SWClient(with: defaults)
            async let info = client.getUserByID(user.id)
            if isMainUser {
                async let friendRequests: () = client.getFriendRequests()
                async let blacklist: () = client.getBlacklist()
                _ = try await (friendRequests, blacklist)
            }
            user = try await info
        } catch {
            setupResponseAlert(ErrorFilter.message(from: error))
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
                setupResponseAlert(ErrorFilter.message(from: error))
            }
            messagingModel.isLoading = false
        }
    }

    func setupResponseAlert(_ message: String) {
        showAlertMessage = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() { alertMessage = "" }

    var isMainUser: Bool {
        user.id == defaults.mainUserInfo?.id
    }

    func cancelTasks() {
        [friendActionTask, sendMessageTask, blacklistUserTask].forEach { $0?.cancel() }
    }
}

private extension UserDetailsView {
    struct SocialActions {
        var friend = FriendAction.sendFriendRequest
        var isFriendRequestSent = false
        var blacklist = BlacklistOption.add
        var isBlacklisted: Bool { blacklist == .remove }
    }
}

#if DEBUG
#Preview {
    UserDetailsView(for: .preview)
        .environmentObject(NetworkStatus())
        .environmentObject(DefaultsService())
}
#endif

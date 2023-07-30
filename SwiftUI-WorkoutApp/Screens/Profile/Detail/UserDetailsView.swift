import DesignSystem
import NetworkStatus
import SwiftUI
import SWModels

/// Экран с детальной информацией профиля
struct UserDetailsView: View {
    @EnvironmentObject private var network: NetworkStatus
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: UserDetailsViewModel
    @StateObject private var messagingViewModel = MessagingViewModel()
    @State private var showMessageSheet = false
    @State private var isFriendRequestSent = false
    @State private var showAlertMessage = false
    @State private var showBlacklistConfirmation = false
    @State private var alertMessage = ""
    @State private var friendActionTask: Task<Void, Never>?
    @State private var sendMessageTask: Task<Void, Never>?
    @State private var blacklistUserTask: Task<Void, Never>?

    init(for user: UserResponse?) {
        _viewModel = StateObject(wrappedValue: .init(with: user))
    }

    init(from model: UserModel) {
        _viewModel = StateObject(wrappedValue: .init(from: model))
    }

    init(from dialog: DialogResponse) {
        _viewModel = StateObject(wrappedValue: .init(from: dialog))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                userInfoSection
                if isMainUser {
                    editProfileButton
                }
                if !isMainUser {
                    communicationSection
                }
                socialInfoSection
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .opacity(viewModel.user.isFull ? 1 : 0)
        .loadingOverlay(if: viewModel.isLoading)
        .background(Color.swBackground)
        .alert(alertMessage, isPresented: $showAlertMessage) {
            Button("Ok", action: closeAlert)
        }
        .refreshable { await askForUserInfo(refresh: true) }
        .onChange(of: viewModel.requestedFriendship, perform: toggleFriendRequestSent)
        .onChange(of: viewModel.responseMessage, perform: setupResponseAlert)
        .onChange(of: messagingViewModel.errorMessage, perform: setupResponseAlert)
        .onChange(of: messagingViewModel.isMessageSent, perform: endMessaging)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                refreshButtonIfNeeded
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Group {
                    if isMainUser {
                        searchUsersButton
                        settingsButton
                    } else {
                        blockUserButton
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onDisappear(perform: cancelTasks)
        .task(priority: .userInitiated) { await askForUserInfo() }
        .navigationTitle(isMainUser ? "" : "Профиль")
    }
}

private extension UserDetailsView {
    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button {
                Task { await askForUserInfo(refresh: true) }
            } label: {
                Image(systemName: Icons.Regular.refresh.rawValue)
            }
            .disabled(viewModel.isLoading)
        }
    }

    var userInfoSection: some View {
        ProfileView(
            imageURL: viewModel.user.imageURL,
            login: viewModel.user.name,
            genderWithAge: viewModel.user.genderWithAge,
            countryAndCity: viewModel.user.shortAddress
        )
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
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
                showMessageSheet.toggle()
            }
            .buttonStyle(SWButtonStyle(icon: .message, mode: .filled, size: .large))
            .sheet(isPresented: $showMessageSheet) { messageSheet }
            Button(viewModel.friendActionOption.rawValue) {
                friendActionTask = Task { await viewModel.friendAction(with: defaults) }
            }
            .buttonStyle(
                SWButtonStyle(
                    icon: viewModel.friendActionOption == .removeFriend
                        ? .deletePerson
                        : .addPerson,
                    mode: .tinted,
                    size: .large
                )
            )
            .alert(Constants.Alert.friendRequestSent, isPresented: $isFriendRequestSent) {
                Button("Ok") {}
            }
        }
        .padding(.bottom, 24)
    }

    var blockUserButton: some View {
        Button {
            showBlacklistConfirmation.toggle()
        } label: {
            Label(
                viewModel.blacklistActionOption.rawValue,
                systemImage: Icons.Regular.exclamation.rawValue
            )
        }
        .confirmationDialog(
            viewModel.blacklistActionOption.dialogTitle,
            isPresented: $showBlacklistConfirmation,
            titleVisibility: .visible
        ) {
            Button(viewModel.blacklistActionOption.rawValue, role: .destructive) {
                blacklistUserTask = Task {
                    await viewModel.blacklistUser(with: defaults)
                }
            }
        } message: {
            Text(viewModel.blacklistActionOption.dialogMessage)
        }
    }

    func toggleFriendRequestSent(isSent: Bool) {
        isFriendRequestSent = isSent
    }

    var socialInfoSection: some View {
        VStack(spacing: 12) {
            if viewModel.user.usesSportsGrounds > .zero {
                usesSportsGroundsButton
            }
            if !viewModel.user.addedSportsGrounds.isEmpty {
                addedSportsGroundsButton
            }
            if viewModel.user.friendsCount > .zero || (isMainUser && friendRequestsCount > .zero) {
                friendsButton
            }
            if !defaults.blacklistedUsers.isEmpty, isMainUser {
                blacklistButton
            }
            if viewModel.user.journalsCount > .zero, !isMainUser {
                journalsButton
            }
        }
    }

    var usesSportsGroundsButton: some View {
        NavigationLink {
            SportsGroundsListView(for: .usedBy(userID: viewModel.user.id))
        } label: {
            FormRowView(
                title: "Где тренируется",
                trailingContent: .textWithChevron(viewModel.user.usesSportsGroundsCountString)
            )
        }
        .accessibilityIdentifier("usesSportsGroundsButton")
    }

    var addedSportsGroundsButton: some View {
        NavigationLink {
            SportsGroundsListView(for: .added(list: viewModel.user.addedSportsGrounds))
        } label: {
            FormRowView(
                title: "Добавил площадки",
                trailingContent: .textWithChevron(viewModel.user.addedSportsGroundsCountString)
            )
        }
    }

    var friendsButton: some View {
        NavigationLink(destination: UsersListView(mode: .friends(userID: viewModel.user.id))) {
            FormRowView(
                title: "Друзья",
                trailingContent: .textWithBadgeAndChevron(
                    viewModel.user.friendsCountString,
                    friendRequestsCount
                )
            )
        }
    }

    var blacklistButton: some View {
        NavigationLink(destination: UsersListView(mode: .blacklist)) {
            FormRowView(
                title: "Черный список",
                trailingContent: .textWithChevron(defaults.blacklistedUsersCountString)
            )
        }
    }

    var journalsButton: some View {
        NavigationLink {
            JournalsListView(for: viewModel.user.id)
                .navigationTitle("Дневники")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            FormRowView(
                title: "Дневники",
                trailingContent: .textWithChevron(viewModel.user.journalsCountString)
            )
        }
    }

    var searchUsersButton: some View {
        NavigationLink(destination: SearchUsersView()) {
            Image(systemName: Icons.Regular.magnifyingglass.rawValue)
        }
        .disabled(!network.isConnected)
        .accessibilityIdentifier("searchUsersButton")
    }

    var settingsButton: some View {
        NavigationLink(destination: ProfileSettingsView(mode: .authorized)) {
            Image(systemName: Icons.Regular.gearshape.rawValue)
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        await viewModel.makeUserInfo(refresh: refresh, with: defaults)
    }

    var messageSheet: some View {
        SendMessageView(
            header: "Новое сообщение",
            text: $messagingViewModel.messageText,
            isLoading: messagingViewModel.isLoading,
            isSendButtonDisabled: !messagingViewModel.canSendMessage,
            sendAction: sendMessage,
            showErrorAlert: $showAlertMessage,
            errorTitle: $alertMessage,
            dismissError: closeAlert
        )
    }

    func sendMessage() {
        sendMessageTask = Task {
            await messagingViewModel.sendMessage(to: viewModel.user.id, with: defaults)
        }
    }

    func endMessaging(isSuccess: Bool) {
        if isSuccess {
            messagingViewModel.messageText = ""
            showMessageSheet.toggle()
        }
    }

    func setupResponseAlert(with message: String) {
        showAlertMessage = !message.isEmpty
        alertMessage = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
        messagingViewModel.clearErrorMessage()
    }

    var friendRequestsCount: Int {
        defaults.friendRequestsList.count
    }

    var isMainUser: Bool {
        viewModel.user.id == defaults.mainUserInfo?.userID
    }

    func cancelTasks() {
        [friendActionTask, sendMessageTask, blacklistUserTask].forEach { $0?.cancel() }
    }
}

#if DEBUG
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(for: .preview)
            .environmentObject(NetworkStatus())
            .environmentObject(DefaultsService())
    }
}
#endif

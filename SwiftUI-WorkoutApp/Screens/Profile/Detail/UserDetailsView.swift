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
        List {
            userInfoSection
            if !isMainUser {
                communicationSection
            }
            socialInfoSection
        }
        .opacity(viewModel.user.isFull ? 1 : 0)
        .loadingOverlay(if: viewModel.isLoading)
        .alert(alertMessage, isPresented: $showAlertMessage) {
            Button("Ok", action: closeAlert)
        }
        .refreshable { await askForUserInfo(refresh: true) }
        .onChange(of: viewModel.requestedFriendship, perform: toggleFriendRequestSent)
        .onChange(of: viewModel.responseMessage, perform: setupResponseAlert)
        .onChange(of: messagingViewModel.errorMessage, perform: setupResponseAlert)
        .onChange(of: messagingViewModel.isMessageSent, perform: endMessaging)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isMainUser {
                    Group {
                        searchUsersButton
                        settingsButton
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onDisappear(perform: cancelTasks)
        .task(priority: .userInitiated) { await askForUserInfo() }
        .navigationTitle("Профиль")
    }
}

private extension UserDetailsView {
    var userInfoSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    avatarImageView
                    VStack(spacing: 4) {
                        Text(viewModel.user.name)
                            .fontWeight(.bold)
                        Text(viewModel.user.gender) + Text("yearsCount \(viewModel.user.age)")
                        Text(viewModel.user.shortAddress)
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
            }
        }
    }

    var avatarImageView: some View {
        CachedImage(url: viewModel.user.imageURL, mode: .profileAvatar)
    }

    var communicationSection: some View {
        Section {
            sendMessageButton
            friendActionButton
            blockUserButton
        }
    }

    var sendMessageButton: some View {
        Button {
            showMessageSheet.toggle()
        } label: {
            Label("Отправить сообщение", systemImage: "plus.message")
        }
        .sheet(isPresented: $showMessageSheet) { messageSheet }
    }

    var friendActionButton: some View {
        Button {
            friendActionTask = Task { await viewModel.friendAction(with: defaults) }
        } label: {
            Label(
                viewModel.friendActionOption.rawValue,
                systemImage: viewModel.friendActionOption.imageName
            )
        }
        .alert(Constants.Alert.friendRequestSent, isPresented: $isFriendRequestSent) {
            Button("Ok") {}
        }
    }

    var blockUserButton: some View {
        Button {
            showBlacklistConfirmation.toggle()
        } label: {
            Label(
                viewModel.blacklistActionOption.rawValue,
                systemImage: Icons.Button.exclamation.rawValue
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
        Section {
            if viewModel.user.usesSportsGrounds > .zero {
                usesSportsGroundsButton
            }
            if !viewModel.user.addedSportsGrounds.isEmpty {
                addedSportsGroundsButton
            }
            if viewModel.user.friendsCount > .zero || (isMainUser && friendRequestsCount > .zero) {
                friendsButton
            }
            if blacklistedUsersCount > .zero, isMainUser {
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
            Label("Где тренируется", systemImage: "mappin.and.ellipse")
                .badge(viewModel.user.usesSportsGrounds.description)
        }
        .accessibilityIdentifier("usesSportsGroundsButton")
    }

    var addedSportsGroundsButton: some View {
        NavigationLink {
            SportsGroundsListView(for: .added(list: viewModel.user.addedSportsGrounds))
        } label: {
            Label("Добавил площадки", systemImage: "mappin.and.ellipse")
                .badge(viewModel.user.addedSportsGrounds.count.description)
        }
    }

    var friendsButton: some View {
        NavigationLink(destination: UsersListView(mode: .friends(userID: viewModel.user.id))) {
            HStack(spacing: 8) {
                Label("Друзья", systemImage: "person.3.sequence.fill")
                Spacer()
                if friendRequestsCount > .zero, isMainUser {
                    Image(systemName: "\(friendRequestsCount).circle.fill")
                        .foregroundColor(.red)
                }
                if viewModel.user.friendsCount > .zero {
                    Text(viewModel.user.friendsCount.description)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    var blacklistButton: some View {
        NavigationLink(destination: UsersListView(mode: .blacklist)) {
            Label("Черный список", systemImage: "text.badge.xmark")
                .badge(blacklistedUsersCount.description)
        }
    }

    var journalsButton: some View {
        NavigationLink {
            JournalsListView(for: viewModel.user.id)
                .navigationTitle("Дневники")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            Label("Дневники", systemImage: "text.book.closed.fill")
                .badge(viewModel.user.journalsCount.description)
        }
    }

    var searchUsersButton: some View {
        NavigationLink(destination: SearchUsersView()) {
            Image(systemName: Icons.Button.magnifyingglass.rawValue)
        }
        .disabled(!network.isConnected)
        .accessibilityIdentifier("searchUsersButton")
    }

    var settingsButton: some View {
        NavigationLink(destination: ProfileSettingsView(mode: .authorized)) {
            Image(systemName: Icons.Button.gearshape.rawValue)
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

    var blacklistedUsersCount: Int {
        defaults.blacklistedUsers.count
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

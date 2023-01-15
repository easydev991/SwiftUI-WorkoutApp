import SwiftUI

/// Экран с детальной информацией профиля
struct UserDetailsView: View {
    @EnvironmentObject private var network: CheckNetworkService
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
        .overlay {
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : 0)
        }
        .animation(.default, value: viewModel.isLoading)
        .disabled(viewModel.isLoading)
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
        CacheImageView(url: viewModel.user.imageURL, mode: .profileAvatar)
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
                systemImage: "exclamationmark.triangle"
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
            if viewModel.user.friendsCount > .zero || friendRequestsCount > .zero {
                friendsButton
            }
            if blacklistedUsersCount > .zero && isMainUser {
                blacklistButton
            }
            if viewModel.user.journalsCount > .zero && !isMainUser {
                journalsButton
            }
        }
    }

    var usesSportsGroundsButton: some View {
        NavigationLink {
            SportsGroundsListView(for: .usedBy(userID: viewModel.user.id))
        } label: {
            HStack {
                Label("Где тренируется", systemImage: "mappin.and.ellipse")
                Spacer()
                Text(viewModel.user.usesSportsGrounds.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var addedSportsGroundsButton: some View {
        NavigationLink {
            SportsGroundsListView(for: .added(list: viewModel.user.addedSportsGrounds))
        } label: {
            HStack {
                Label("Добавил площадки", systemImage: "mappin.and.ellipse")
                Spacer()
                Text(viewModel.user.addedSportsGrounds.count.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var friendsButton: some View {
        NavigationLink(destination: UsersListView(mode: .friends(userID: viewModel.user.id))) {
            HStack {
                Label("Друзья", systemImage: "person.3.sequence.fill")
                Spacer()
                if friendRequestsCount > .zero && isMainUser {
                    Image(systemName: "\(friendRequestsCount).circle.fill")
                        .foregroundColor(.red)
                }
                Text(viewModel.user.friendsCount.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var blacklistButton: some View {
        NavigationLink(destination: UsersListView(mode: .blacklist)) {
            HStack {
                Label("Черный список", systemImage: "text.badge.xmark")
                Spacer()
                Text(blacklistedUsersCount.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var journalsButton: some View {
        NavigationLink {
            JournalsListView(for: viewModel.user.id)
                .navigationTitle("Дневники")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Дневники", systemImage: "text.book.closed.fill")
                Spacer()
                Text(viewModel.user.journalsCount.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var searchUsersButton: some View {
        NavigationLink(destination: SearchUsersView()) {
            Image(systemName: "magnifyingglass")
        }
        .disabled(!network.isConnected)
    }

    var settingsButton: some View {
        NavigationLink(destination: ProfileSettingsView(mode: .authorized)) {
            Image(systemName: "gearshape.fill")
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        await viewModel.makeUserInfo(refresh: refresh, with: defaults)
        if isMainUser {
            await viewModel.checkFriendRequests(with: defaults)
            await viewModel.checkBlacklist(with: defaults)
        }
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
            .environmentObject(CheckNetworkService())
            .environmentObject(DefaultsService())
    }
}
#endif

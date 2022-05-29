import SwiftUI

/// Экран с детальной информацией профиля
struct UserDetailsView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel: UserDetailsViewModel
    @State private var isMessaging = false
    @State private var messageText = ""
    @State private var isFriendRequestSent = false
    @State private var showErrorAlert = false
    @State private var errorTitle = ""
    @State private var friendActionTask: Task<Void, Never>?
    @State private var sendMessageTask: Task<Void, Never>?

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
        ZStack {
            Form {
                userInfoSection
                if !isMainUser {
                    communicationSection
                }
                socialInfoSection
            }
            .disabled(viewModel.isLoading)
            .opacity(viewModel.user.isFull ? 1 : .zero)
            .animation(.default, value: viewModel.isLoading)
            ProgressView()
                .opacity(viewModel.isLoading ? 1 : .zero)
        }
        .alert(errorTitle, isPresented: $showErrorAlert) {
            Button(action: closeAlert) { TextOk() }
        }
        .refreshable { await askForUserInfo(refresh: true) }
        .onChange(of: viewModel.requestedFriendship, perform: toggleFriendRequestSent)
        .onChange(of: viewModel.errorMessage, perform: setupErrorAlert)
        .onChange(of: viewModel.isMessageSent, perform: endMessaging)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if isMainUser {
                    Group {
                        searchUsersLink
                        settingsLink
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
                        Text(viewModel.user.gender) + Text("yearsCount \(viewModel.user.age)", tableName: "Plurals")
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
            sendMessageLink
            friendActionButton
        }
    }

    var sendMessageLink: some View {
        Button {
            isMessaging.toggle()
        } label: {
            Text("Отправить сообщение")
                .fontWeight(.medium)
        }
        .sheet(isPresented: $isMessaging) { messageSheet }
    }

    var friendActionButton: some View {
        Button {
            friendActionTask = Task { await viewModel.friendAction() }
        } label: {
            Text(viewModel.friendActionOption.rawValue)
                .fontWeight(.medium)
        }
        .alert(Constants.Alert.friendRequestSent, isPresented: $isFriendRequestSent) {
            Button {} label: { TextOk() }
        }
    }

    func toggleFriendRequestSent(isSent: Bool) {
        isFriendRequestSent = isSent
    }

    var socialInfoSection: some View {
        Section {
            if viewModel.user.usesSportsGrounds > .zero {
                usesSportsGroundsLink
            }
            if !viewModel.user.addedSportsGrounds.isEmpty {
                addedSportsGroundsLink
            }
            if viewModel.user.friendsCount > .zero || friendRequestsCount > .zero {
                friendsLink
            }
            if viewModel.user.journalsCount > .zero && !isMainUser {
                journalsLink
            }
        }
    }

    var usesSportsGroundsLink: some View {
        NavigationLink {
            SportsGroundsListView(for: .usedBy(userID: viewModel.user.id))
                .navigationTitle("Где тренируется")
        } label: {
            HStack {
                Label("Где тренируется", systemImage: "mappin.and.ellipse")
                Spacer()
                Text(viewModel.user.usesSportsGrounds.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var addedSportsGroundsLink: some View {
        NavigationLink {
            SportsGroundsListView(for: .added(list: viewModel.user.addedSportsGrounds))
                .navigationTitle("Добавленные")
        } label: {
            Label("Добавил площадки", systemImage: "mappin.and.ellipse")
            Spacer()
            Text(viewModel.user.addedSportsGrounds.count.description)
                .foregroundColor(.secondary)
        }
    }

    var friendsLink: some View {
        NavigationLink {
            UsersListView(mode: .friends(userID: viewModel.user.id))
                .navigationTitle("Друзья")
        } label: {
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

    var journalsLink: some View {
        NavigationLink {
            JournalsList(for: viewModel.user.id)
                .navigationTitle("Дневники")
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Label("Дневники", systemImage: "list.bullet")
                Spacer()
                Text(viewModel.user.journalsCount.description)
                    .foregroundColor(.secondary)
            }
        }
    }

    var searchUsersLink: some View {
        NavigationLink(destination: SearchUsersView()) {
            Image(systemName: "magnifyingglass")
        }
    }

    var settingsLink: some View {
        NavigationLink(destination: ProfileSettingsView()) {
            Image(systemName: "gearshape.fill")
        }
    }

    func askForUserInfo(refresh: Bool = false) async {
        await viewModel.makeUserInfo(with: defaults, refresh: refresh)
        if isMainUser {
            await viewModel.checkFriendRequests(with: defaults)
        }
    }

    var messageSheet: some View {
        SendMessageView(
            text: $messageText,
            isLoading: viewModel.isLoading,
            isSendButtonDisabled: messageText.isEmpty || viewModel.isLoading,
            sendAction: sendMessage,
            showErrorAlert: $showErrorAlert,
            errorTitle: $errorTitle,
            dismissError: closeAlert
        )
    }

    func sendMessage() {
        sendMessageTask = Task {
            await viewModel.send(messageText, with: defaults)
        }
    }

    func endMessaging(isSuccess: Bool) {
        if isSuccess {
            messageText = ""
            isMessaging.toggle()
        }
    }

    func setupErrorAlert(with message: String) {
        showErrorAlert = !message.isEmpty
        errorTitle = message
    }

    func closeAlert() {
        viewModel.clearErrorMessage()
    }

    var friendRequestsCount: Int {
        defaults.friendRequestsList.count
    }

    var isMainUser: Bool {
        viewModel.user.id == defaults.mainUserID
    }

    func cancelTasks() {
        [friendActionTask, sendMessageTask].forEach { $0?.cancel() }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(for: .emptyValue)
            .environmentObject(DefaultsService())
    }
}

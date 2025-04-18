import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с профилем главного пользователя
struct MainUserProfileScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var refreshTask: Task<Void, Never>?
    @State private var isLoading = false
    @State private var showLogoutDialog = false
    @State private var showSearchUsersScreen = false
    private var client: SWClient { SWClient(with: defaults) }

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    authorizedContentView
                        .navigationBarTitleDisplayMode(.inline)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    IncognitoProfileView()
                }
            }
            .animation(.spring, value: defaults.isAuthorized)
            .background(Color.swBackground)
            .navigationTitle("Профиль")
        }
        .navigationViewStyle(.stack)
        .task { await askForUserInfo() }
        .onChange(of: scenePhase) { phase in
            if case .active = phase {
                refreshTask = Task { await askForUserInfo(refresh: true) }
            }
        }
    }
}

private extension MainUserProfileScreen {
    var authorizedContentView: some View {
        ScrollView {
            if let user = defaults.mainUserInfo {
                makeProfileContent(for: user)
            }
        }
        .frame(maxWidth: .infinity)
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .refreshable { await askForUserInfo(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                refreshButtonIfNeeded
            }
            ToolbarItem(placement: .topBarTrailing) {
                searchUsersButton
                    .disabled(isLoading)
            }
        }
    }

    @ViewBuilder
    func makeProfileContent(for user: UserResponse) -> some View {
        VStack(spacing: 0) {
            ProfileViews.makeUserInfo(for: user)
                .id(defaults.mainUserInfo?.avatarURL)
            editProfileButton
            VStack(spacing: 12) {
                ProfileViews.makeFriends(
                    for: user,
                    isMainUser: true,
                    friendRequestsCount: defaults.friendRequestsList.count
                )
                ProfileViews.makeUsedParks(for: user)
                ProfileViews.makeAddedParks(for: user)
                ProfileViews.makeJournals(for: user, isMainUser: true)
                blacklistButtonIfNeeded
            }
            logoutButton
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    var refreshButtonIfNeeded: some View {
        if !DeviceOSVersionChecker.iOS16Available {
            Button {
                guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
                Task { await askForUserInfo(refresh: true) }
            } label: {
                Icons.Regular.refresh.view
            }
            .disabled(isLoading)
        }
    }

    var searchUsersButton: some View {
        Button {
            showSearchUsersScreen = true
        } label: {
            Icons.Regular.magnifyingglass.view
        }
        .accessibilityIdentifier("searchUsersButton")
        .sheet(isPresented: $showSearchUsersScreen) {
            NavigationView {
                SearchUsersScreen()
            }
            .navigationViewStyle(.stack)
        }
    }

    var editProfileButton: some View {
        NavigationLink(destination: EditProfileScreen()) {
            Text("Изменить профиль")
        }
        .buttonStyle(SWButtonStyle(icon: .pencil, mode: .tinted, size: .large))
        .padding(.bottom, 24)
    }

    @ViewBuilder
    var blacklistButtonIfNeeded: some View {
        ZStack {
            if !defaults.blacklistedUsers.isEmpty {
                NavigationLink(destination: BlackListScreen()) {
                    FormRowView(
                        title: "Черный список",
                        trailingContent: .textWithChevron(defaults.blacklistedUsersCountString)
                    )
                }
            }
        }
        .animation(.default, value: defaults.blacklistedUsers.isEmpty)
    }

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

    func askForUserInfo(refresh: Bool = false) async {
        guard let userId = defaults.mainUserInfo?.id else { return }
        guard !isLoading else { return }
        if !refresh || defaults.needUpdateUser { isLoading = true }
        if refresh || defaults.needUpdateUser {
            do {
                let result = try await client.getSocialUpdates(userID: userId)
                try defaults.saveFriendsIds(result.friends.map(\.id))
                try defaults.saveFriendRequests(result.friendRequests)
                try defaults.saveBlacklist(result.blacklist)
                try defaults.saveUserInfo(result.user)
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
        }
        isLoading = false
    }
}

#if DEBUG
#Preview {
    MainUserProfileScreen()
}
#endif

import SWAlert
import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient

/// Экран с профилем главного пользователя
struct MainUserProfileScreen: View {
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var isLoading = false
    @State private var showLogoutDialog = false
    @State private var showSearchUsersScreen = false
    private var client: SWClient { SWClient(with: defaults) }

    var body: some View {
        ScrollView {
            if let user = defaults.mainUserInfo {
                makeProfileContent(for: user)
            }
        }
        .frame(maxWidth: .infinity)
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .refreshable { await askForUserInfo(refresh: true) }
        .task { await askForUserInfo() }
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
}

private extension MainUserProfileScreen {
    @ViewBuilder
    func makeProfileContent(for user: UserResponse) -> some View {
        VStack(spacing: 0) {
            ProfileViews.makeUserInfo(for: user)
                .id(defaults.mainUserInfo?.avatarURL)
            editProfileButton
            VStack(spacing: 12) {
                ProfileViews.makeFriends(
                    for: user,
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
        .disabled(!isNetworkConnected)
        .accessibilityIdentifier("searchUsersButton")
        .sheet(isPresented: $showSearchUsersScreen) {
            NavigationView {
                SearchUsersScreen()
            }
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
                NavigationLink(destination: UsersListScreen(mode: .blacklist)) {
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
        guard !isLoading else { return }
        if !refresh { isLoading = true }
        if refresh || defaults.needUpdateUser {
            await makeUserInfo()
        }
        isLoading = false
    }

    func makeUserInfo() async {
        guard let mainUserId = defaults.mainUserInfo?.id else { return }
        do {
            // TODO: вынести обновление заявок/черного списка в отдельную логику
            async let getUserInfo = client.getUserByID(mainUserId)
            async let getFriendRequests = client.getFriendRequests()
            async let getBlacklist = client.getBlacklist()
            let (userInfo, friendRequests, blacklist) = try await (getUserInfo, getFriendRequests, getBlacklist)
            try defaults.saveUserInfo(userInfo)
            try defaults.saveFriendRequests(friendRequests)
            try defaults.saveBlacklist(blacklist)
        } catch {
            SWAlert.shared.present(message: ErrorFilter.message(from: error))
        }
    }
}

#if DEBUG
#Preview {
    MainUserProfileScreen()
}
#endif

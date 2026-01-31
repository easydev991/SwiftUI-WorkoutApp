import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран с профилем главного пользователя
struct MainUserProfileScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var defaults: DefaultsService
    @State private var showLogoutDialog = false
    @State private var showSearchUsersScreen = false

    var body: some View {
        NavigationStack {
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
        .task { await askForUserInfo() }
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
        .loadingOverlay(if: viewModel.currentState.isLoading)
        .background(Color.swBackground)
        .refreshable { await askForUserInfo(refresh: true) }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                searchUsersButton
            }
        }
    }

    func makeProfileContent(for user: UserResponse) -> some View {
        VStack(spacing: 0) {
            ProfileViews.makeUserInfo(for: user)
                .id(defaults.mainUserInfo?.avatarURL)
            editProfileButton
                .swBadge(user.badgeValue)
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

    var searchUsersButton: some View {
        Button {
            showSearchUsersScreen = true
        } label: {
            Icons.Regular.magnifyingglass.view
        }
        .tint(.accent)
        .disabled(viewModel.currentState.isLoading)
        .accessibilityIdentifier("searchUsersButton")
        .sheet(isPresented: $showSearchUsersScreen) {
            NavigationStack {
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
                .init(Strings.Alert.logout),
                isPresented: $showLogoutDialog,
                titleVisibility: .visible
            ) {
                Button("Выйти", role: .destructive) {
                    defaults.triggerLogout()
                }
            }
    }

    func askForUserInfo(refresh: Bool = false) async {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        do {
            try await viewModel.getUserProfile(refresh: refresh, defaults: defaults)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }
}

#if DEBUG
#Preview {
    MainUserProfileScreen()
        .environmentObject(MainUserProfileScreen.ViewModel())
        .environmentObject(DefaultsService(authHelper: MockAuthHelper()))
        .networkStatus(true)
}
#endif

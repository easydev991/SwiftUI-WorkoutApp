import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком входящих заявок и друзей основного пользователя
struct MainUserFriendsListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var defaults: DefaultsService
    @State private var friendRequests = [UserResponse]()
    @State private var friends = [UserResponse]()
    @State private var isLoading = false
    @State private var friendRequestTask: Task<Void, Never>?
    private var client: SWClient { SWClient(with: defaults) }
    let userId: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FriendRequestsView(
                    friendRequests: friendRequests,
                    action: respondToFriendRequest
                )
                friendsSectionIfNeeded
            }
            .padding([.horizontal, .bottom])
            .frame(maxWidth: .infinity)
        }
        .loadingOverlay(if: isLoading)
        .background(Color.swBackground)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationTitle("Друзья")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension MainUserFriendsListScreen {
    var friendsSectionIfNeeded: some View {
        ZStack {
            if !friends.isEmpty {
                SectionView(
                    headerWithPadding: friendRequests.isEmpty ? nil : "Друзья",
                    mode: .regular
                ) {
                    LazyVStack(spacing: 12) {
                        ForEach(friends) { user in
                            NavigationLink {
                                UserDetailsScreen(for: user)
                            } label: {
                                userRowView(with: user)
                            }
                            .disabled(user.id == defaults.mainUserInfo?.id)
                        }
                    }
                }
            }
        }
        .animation(.default, value: friends)
    }

    func userRowView(with model: UserResponse) -> some View {
        UserRowView(
            mode: .regular(
                .init(
                    imageURL: model.avatarURL,
                    name: model.userName ?? "",
                    address: SWAddress(model.countryID, model.cityID)?.address ?? ""
                )
            )
        )
    }

    func askForUsers(refresh: Bool = false) async {
        guard !isLoading else { return }
        let needUpdate = defaults.needUpdateUser
        let isEmpty = [friends, friendRequests].allSatisfy(\.isEmpty)
        guard isEmpty || refresh || needUpdate else { return }
        do {
            if !refresh || needUpdate { isLoading = true }
            try await getFriendsAndRequests()
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
        isLoading = false
    }

    func respondToFriendRequest(from userID: Int, accept: Bool) {
        isLoading = true
        friendRequestTask = Task {
            do {
                let isSuccess = try await client.respondToFriendRequest(from: userID, accept: accept)
                if isSuccess {
                    friendRequests.removeAll(where: { $0.id == userID })
                    try await getFriendsAndRequests()
                }
            } catch {
                SWAlert.shared.presentDefaultUIKit(error)
            }
            isLoading = false
        }
    }

    func getFriendsAndRequests() async throws {
        async let friendsTask = client.getFriendsForUser(id: userId)
        async let requestsTask = client.getFriendRequests()
        let (friends, requests) = try await (friendsTask, requestsTask)
        self.friends = friends
        friendRequests = requests
        try defaults.saveFriendsIds(friends.map(\.id))
        try defaults.saveFriendRequests(requests)
    }
}

#if DEBUG
#Preview {
    MainUserFriendsListScreen(userId: UserResponse.preview.id)
        .environmentObject(DefaultsService())
}
#endif

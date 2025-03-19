import SWDesignSystem
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Экран со списком входящих заявок и друзей основного пользователя
struct MainUserFriendsListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isNetworkConnected) private var isNetworkConnected
    @EnvironmentObject private var defaults: DefaultsService
    @State private var currentState = CurrentState.initial
    private var client: SWClient { SWClient(with: defaults) }
    let userId: Int

    var body: some View {
        ScrollView {
            contentView
                .frame(maxWidth: .infinity)
                .animation(.default, value: currentState)
                .padding([.horizontal, .bottom])
        }
        .onChange(of: currentState) { newState in
            if newState.isReadyAndEmpty {
                dismiss()
            }
        }
        .loadingOverlay(if: currentState.isLoading)
        .background(Color.swBackground)
        .task { await askForUsers() }
        .refreshable { await askForUsers(refresh: true) }
        .navigationTitle("Друзья")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension MainUserFriendsListScreen {
    enum CurrentState: Equatable {
        case initial
        /// Загрузка с нуля или рефреш
        case loading
        /// Принятие/отклонение заявки из состояния `ready`
        ///
        /// Заявки и друзья нужны, чтобы не обнулять список на экране
        case friendRequestAction(friendRequests: [UserResponse], friends: [UserResponse])
        case ready(friendRequests: [UserResponse], friends: [UserResponse])
        case error(ErrorKind)

        var isLoading: Bool {
            switch self {
            case .loading, .friendRequestAction: true
            default: false
            }
        }

        /// Нужно ли загружать данные, когда их нет (или для рефреша)
        var shouldLoad: Bool {
            switch self {
            case .initial, .error: true
            case let .ready(requests, friends): requests.isEmpty && friends.isEmpty
            case .loading, .friendRequestAction: false
            }
        }

        var isReadyAndNotEmpty: Bool {
            switch self {
            case let .ready(requests, friends): !requests.isEmpty || !friends.isEmpty
            default: false
            }
        }

        /// Если `true`, нужно закрыть экран
        var isReadyAndEmpty: Bool {
            if case let .ready(friendRequests, friends) = self {
                friendRequests.isEmpty && friends.isEmpty
            } else {
                false
            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch currentState {
        case let .ready(friendRequests, friends),
             let .friendRequestAction(friendRequests, friends):
            VStack(spacing: 16) {
                FriendRequestsView(
                    friendRequests: friendRequests,
                    action: respondToFriendRequest
                )
                makeFriendsSectionIfNeeded(
                    friends: friends,
                    hasFriendRequests: !friendRequests.isEmpty
                )
            }
        case let .error(errorKind):
            CommonErrorView(errorKind: errorKind)
        case .initial, .loading:
            ContainerRelativeView {
                Text("Загрузка...")
            }
        }
    }

    @ViewBuilder
    func makeFriendsSectionIfNeeded(
        friends: [UserResponse],
        hasFriendRequests: Bool
    ) -> some View {
        if !friends.isEmpty {
            SectionView(
                headerWithPadding: hasFriendRequests ? "Друзья" : nil,
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
        let needUpdateUser = defaults.needUpdateUser
        guard currentState.shouldLoad || needUpdateUser || refresh else { return }
        guard isNetworkConnected else {
            if currentState.isReadyAndNotEmpty {
                SWAlert.shared.presentNoConnection(false)
            } else {
                currentState = .error(.notConnected)
            }
            return
        }
        if !refresh {
            currentState = .loading
        }
        do {
            try await getFriendsAndRequests()
        } catch {
            currentState = .error(.common(message: error.localizedDescription))
        }
    }

    func respondToFriendRequest(from userID: Int, accept: Bool) {
        guard !SWAlert.shared.presentNoConnection(isNetworkConnected) else { return }
        guard case let .ready(requests, friends) = currentState else { return }
        currentState = .friendRequestAction(friendRequests: requests, friends: friends)
        Task {
            do {
                try await client.respondToFriendRequest(from: userID, accept: accept)
                defaults.setUserNeedUpdate(true)
                try await getFriendsAndRequests()
            } catch {
                currentState = .ready(friendRequests: requests, friends: friends)
                SWAlert.shared.presentDefaultUIKit(error)
            }
        }
    }

    func getFriendsAndRequests() async throws {
        async let friendsTask = client.getFriendsForUser(id: userId)
        async let requestsTask = client.getFriendRequests()
        let (friends, requests) = try await (friendsTask, requestsTask)
        currentState = .ready(friendRequests: requests, friends: friends)
        do {
            try defaults.saveFriendsIds(friends.map(\.id))
            try defaults.saveFriendRequests(requests)
        } catch {
            SWAlert.shared.presentDefaultUIKit(error)
        }
    }
}

#if DEBUG
#Preview {
    MainUserFriendsListScreen(userId: UserResponse.preview.id)
        .environmentObject(DefaultsService())
}
#endif

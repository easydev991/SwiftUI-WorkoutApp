import Foundation
import SWModels
import SWNetworkClient

extension MainUserProfileScreen {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var currentState = CurrentState.initial

        func getUserProfile(
            refresh: Bool = false,
            defaults: DefaultsService
        ) async throws {
            guard defaults.isAuthorized, let userId = defaults.mainUserInfo?.id else {
                currentState = .initial
                return
            }
            let shouldLoad = currentState.shouldLoad(defaults.needUpdateUser)
            guard shouldLoad || refresh else {
                return
            }
            if !refresh || defaults.needUpdateUser {
                currentState = .loading
            }
            let result = try await SWClient(with: defaults).getSocialUpdates(userId: userId)
            try defaults.saveFriendsIds(result.friends.map(\.id))
            try defaults.saveFriendRequests(result.friendRequests)
            try defaults.saveBlacklist(result.blacklist)
            try defaults.saveUserInfo(result.user)
            currentState = .ready
        }
    }
}

extension MainUserProfileScreen {
    enum CurrentState: Equatable {
        case initial
        case loading
        case ready

        var isLoading: Bool {
            if case .loading = self { true } else { false }
        }

        /// Нужно ли загружать данные, когда их нет (или для рефреша)
        func shouldLoad(_ needUpdate: Bool) -> Bool {
            switch self {
            case .initial: true
            case .ready: needUpdate
            case .loading: false
            }
        }
    }
}

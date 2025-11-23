import Foundation
import OSLog
import SWModels
import SWNetworkClient

extension MainUserProfileScreen {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var currentState = CurrentState.initial
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "SwiftUI-WorkoutApp",
            category: "MainUserProfileScreen.ViewModel"
        )
        private let isUITest: Bool

        init(isUITest: Bool = false) {
            self.isUITest = isUITest
        }

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
            logger.info("Начинаем загрузку профиля (refresh: \(refresh), needUpdate: \(defaults.needUpdateUser))")

            // Создаем новый клиент для каждого запроса, как в main-ветке
            // Это решает проблему с параллельными запросами при pull-to-refresh
            #if DEBUG
            let client: ProfileClient = isUITest
                ? MockSWClient(instantResponse: true)
                : SWClient(with: defaults.authHelper)
            #else
            let client: ProfileClient = SWClient(with: defaults.authHelper)
            #endif
            do {
                let result = try await client.getSocialUpdates(userId: userId)
                try defaults.saveFriendsIds(result.friends.map(\.id))
                try defaults.saveFriendRequests(result.friendRequests)
                try defaults.saveBlacklist(result.blacklist)
                try defaults.saveUserInfo(result.user)
                currentState = .ready
                logger.info("Профиль загружен успешно")
            } catch {
                guard !Task.isCancelled else {
                    logger.info("Загрузка профиля отменена (новый запрос или закрытие экрана)")
                    return
                }
                // При других ошибках сбрасываем состояние на основе наличия данных
                if defaults.mainUserInfo != nil {
                    currentState = .ready
                    logger.info("Устанавливаем состояние .ready (есть кэшированные данные)")
                } else {
                    currentState = .initial
                    logger.info("Устанавливаем состояние .initial (нет данных)")
                }
                throw error
            }
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

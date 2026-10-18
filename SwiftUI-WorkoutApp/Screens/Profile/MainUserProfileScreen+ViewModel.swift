import Foundation
import OSLog
import SWModels
import SWNetworkClient

extension MainUserProfileScreen {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var currentState = CurrentState.initial
        /// Идёт загрузка — повторные вызовы (вкладка + возврат в .active) дедуплицируются (план шаг 3)
        private var isInFlight = false
        /// Refresh, пришедший во время загрузки: повторится после её окончания вместо тихого пропуска
        private var reloadQueued = false
        private let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "SwiftUI-WorkoutApp",
            category: "MainUserProfileScreen.ViewModel"
        )
        private let isUITest: Bool
        private let analytics: AnalyticsService
        /// Фабрика клиента профиля для инъекции мока в тестах; `nil` — клиент создаётся как обычно
        private let makeProfileClient: ((AuthHelper) -> ProfileClient)?

        init(
            isUITest: Bool = false,
            analytics: AnalyticsService = AnalyticsService(),
            makeProfileClient: ((AuthHelper) -> ProfileClient)? = nil
        ) {
            self.isUITest = isUITest
            self.analytics = analytics
            self.makeProfileClient = makeProfileClient
        }

        func getUserProfile(
            refresh: Bool = false,
            defaults: DefaultsService
        ) async throws {
            guard defaults.isAuthorized, let userId = defaults.mainUserInfo?.id else {
                currentState = .initial
                return
            }
            guard !isInFlight else {
                // Refresh во время загрузки не теряем — повторим сразу после неё
                if refresh {
                    reloadQueued = true
                }
                logger.info("Загрузка профиля уже идёт, повтор вызова отложен")
                return
            }
            let shouldLoad = currentState.shouldLoad(defaults.needUpdateUser)
            guard shouldLoad || refresh else {
                return
            }
            isInFlight = true
            do {
                try await loadProfile(userId: userId, defaults: defaults)
            } catch {
                await restartQueuedReload(defaults: defaults)
                throw error
            }
            await restartQueuedReload(defaults: defaults)
        }

        /// Загружает профиль; `isInFlight` сбрасывается при любом исходе
        private func loadProfile(userId: Int, defaults: DefaultsService) async throws {
            defer { isInFlight = false }
            // После guard кэш (mainUserInfo) есть всегда — загрузка идёт фоном,
            // блокирующее состояние загрузки не показываем (offline-first, план шаг 1)
            logger.info("Начинаем загрузку профиля (needUpdate: \(defaults.needUpdateUser))")

            let client: ProfileClient
            #if DEBUG
            if isUITest {
                client = MockSWClient(instantResponse: true)
            } else {
                client = makeProfileClient?(defaults.authHelper) ?? SWClient(with: defaults.authHelper)
            }
            #else
            client = makeProfileClient?(defaults.authHelper) ?? SWClient(with: defaults.authHelper)
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
                analytics.log(.appError(kind: .profileLoadFailed, error: error))
                // При ошибке обновления сбрасываем состояние на основе наличия данных
                if defaults.mainUserInfo != nil {
                    // Тихий фолбэк: кэш уже на экране, алерт не показываем (план шаг 2);
                    // удаление аккаунта на сервере страхует форс-логаут по 401
                    currentState = .ready
                    logger.error("Обновление профиля не удалось, показываем кэш: \(String(describing: error))")
                } else {
                    currentState = .initial
                    logger.info("Устанавливаем состояние .initial (нет данных)")
                    throw error
                }
            }
        }

        /// Отложенный проход после загрузки идёт по dirty-флагу: после успеха данные свежие
        /// и клиент не вызывается, после падения загрузка повторяется сразу
        private func restartQueuedReload(defaults: DefaultsService) async {
            guard reloadQueued else { return }
            reloadQueued = false
            do {
                try await getUserProfile(refresh: false, defaults: defaults)
            } catch {
                logger.error("Отложенное обновление профиля не удалось: \(error.localizedDescription)")
            }
        }
    }
}

extension MainUserProfileScreen {
    enum CurrentState: Equatable {
        case initial
        case ready

        /// Нужно ли загружать данные, когда их нет (или для рефреша)
        func shouldLoad(_ needUpdate: Bool) -> Bool {
            switch self {
            case .initial: true
            case .ready: needUpdate
            }
        }
    }
}

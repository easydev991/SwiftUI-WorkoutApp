import Foundation
import SWModels
import SWNetworkClient
import Testing
@testable import WorkoutApp

extension UserDefaultsIsolatedTests {
    /// Гейт-тесты при ошибке координации зависают, а не падают — лимит превращает зависание в отказ
    @Suite(.timeLimit(.minutes(1)))
    @MainActor
    struct MainUserProfileScreenViewModelTests {
        @Test("При непустом кэше загрузка идёт фоном, состояние остаётся .initial")
        func nonEmptyCacheDoesNotMoveStateToLoading() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: true, paused: true)

            let task = Task { try await viewModel.getUserProfile(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)

            #expect(viewModel.currentState == .initial)

            client.gate.resumeAll()
            try await task.value

            #expect(viewModel.currentState == .ready)
            #expect(client.getSocialUpdatesCallCount == 1)
        }

        @Test("При пустом кэше (не авторизован) загрузка не начинается, состояние остаётся .initial")
        func emptyCacheDoesNotStartLoading() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: false)

            try await viewModel.getUserProfile(defaults: defaults)

            #expect(viewModel.currentState == .initial)
            #expect(client.getSocialUpdatesCallCount == 0)
        }

        @Test("При ошибке обновления и непустом кэше ошибка не пробрасывается, состояние .ready")
        func clientErrorWithCacheDoesNotThrowAndKeepsReadyState() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: true, failing: true)

            try await viewModel.getUserProfile(defaults: defaults)

            #expect(viewModel.currentState == .ready)
            #expect(client.getSocialUpdatesCallCount == 1)
        }

        @Test("При ошибке загрузки без кэша (логаут во время запроса) ошибка пробрасывается, состояние .initial")
        func clientErrorWithoutCacheThrowsAndKeepsInitialState() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: true, paused: true, failing: true)

            let task = Task { try await viewModel.getUserProfile(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)
            defaults.triggerLogout(manually: false)

            client.gate.resumeAll()

            await #expect(throws: MockSocialUpdatesClient.MockError.self) {
                try await task.value
            }

            #expect(viewModel.currentState == .initial)
            #expect(client.getSocialUpdatesCallCount == 1)
        }

        @Test("Отложенный refresh после успешной загрузки не идёт в клиент повторно")
        func queuedRefreshAfterSuccessfulLoadDoesNotCallClient() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: true, paused: true)

            let first = Task { try await viewModel.getUserProfile(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)

            // Второй запуск с refresh: true — путь updateProfileIfNeeded при .active;
            // прямой вызов: guard срабатывает до первого await, пока первый запрос стоит в паузе
            try await viewModel.getUserProfile(refresh: true, defaults: defaults)
            #expect(client.getSocialUpdatesCallCount == 1)

            client.gate.resumeAll()
            try await first.value

            // Данные уже свежие — отложенный проход не обращается к клиенту
            #expect(client.getSocialUpdatesCallCount == 1)
            #expect(viewModel.currentState == .ready)
        }

        @Test("Отложенный refresh после падения загрузки повторяется сразу")
        func queuedRefreshAfterFailedLoadRetriesImmediately() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: true, paused: true, failing: true)
            // Падение загрузки не очищает dirty-флаг — как в проде при устаревших данных
            defaults.setUserNeedUpdate(true)

            let first = Task { try await viewModel.getUserProfile(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)
            try await viewModel.getUserProfile(refresh: true, defaults: defaults)

            client.gate.resumeAll()
            try await first.value

            // Первая загрузка упала (тихий фолбэк на кэш), отложенный проход повторил запрос
            #expect(viewModel.currentState == .ready)
            #expect(client.getSocialUpdatesCallCount == 2)
        }

        @Test("После завершения загрузки следующий вызов снова обращается к клиенту")
        func callAfterFinishedLoadCallsClientAgain() async throws {
            let (viewModel, defaults, client) = try makeViewModel(withCache: true, paused: true)

            let first = Task { try await viewModel.getUserProfile(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)
            client.gate.resumeAll()
            try await first.value

            let callsAfterFirstLoad = client.getSocialUpdatesCallCount
            try await viewModel.getUserProfile(refresh: true, defaults: defaults)

            #expect(client.getSocialUpdatesCallCount == callsAfterFirstLoad + 1)
        }
    }
}

// MARK: - Вспомогательные методы

private extension UserDefaultsIsolatedTests.MainUserProfileScreenViewModelTests {
    func makeViewModel(
        withCache: Bool,
        paused: Bool = false,
        failing: Bool = false
    ) throws -> (MainUserProfileScreen.ViewModel, DefaultsService, MockSocialUpdatesClient) {
        let defaults = TestDefaults.makeDefaultsService().0
        if withCache {
            try defaults.saveUserInfo(UserResponse(id: 1, userName: "user"))
        }
        let client = MockSocialUpdatesClient()
        client.gate.pauseFirstCalls = paused ? 1 : 0
        client.shouldThrowError = failing
        let viewModel = MainUserProfileScreen.ViewModel(makeProfileClient: { _ in client })
        return (viewModel, defaults, client)
    }
}

import Foundation
import SWModels
import SWNetworkClient
import Testing
@testable import WorkoutApp

extension UserDefaultsIsolatedTests {
    /// Гейт-тесты при ошибке координации зависают, а не падают — лимит превращает зависание в отказ
    @Suite(.timeLimit(.minutes(1)))
    @MainActor
    struct DialogsListScreenViewModelTests {
        @Test("Повторный refresh во время идущей загрузки не идёт в клиент сразу, а повторяется после неё")
        func duplicateRefreshDuringInFlightLoadIsQueuedAndRunsAfter() async throws {
            let defaults = TestDefaults.makeDefaultsService().0
            try defaults.saveUserInfo(UserResponse(id: 1, userName: "user"))
            let client = MockMessagesClient()
            client.gate.pauseFirstCalls = 1
            let viewModel = DialogsListScreen.ViewModel(
                isUITest: false,
                authHelper: MockAuthHelperForDefaultsService(),
                analytics: AnalyticsService(),
                makeDialogsClient: { _ in client }
            )

            let first = Task { await viewModel.getDialogs(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)

            // Прямой вызов: guard срабатывает до первого await, пока первый запрос стоит в паузе
            await viewModel.getDialogs(refresh: true, defaults: defaults)
            #expect(client.getDialogsCallCount == 1)

            client.gate.resumeAll()
            await first.value

            // Отложенный refresh выполнился после окончания первой загрузки
            #expect(client.getDialogsCallCount == 2)
            #expect(viewModel.currentState == .ready([]))
        }

        @Test("После завершения загрузки следующий вызов снова обращается к клиенту")
        func callAfterFinishedLoadCallsClientAgain() async throws {
            let defaults = TestDefaults.makeDefaultsService().0
            try defaults.saveUserInfo(UserResponse(id: 1, userName: "user"))
            let client = MockMessagesClient()
            client.gate.pauseFirstCalls = 1
            let viewModel = DialogsListScreen.ViewModel(
                isUITest: false,
                authHelper: MockAuthHelperForDefaultsService(),
                analytics: AnalyticsService(),
                makeDialogsClient: { _ in client }
            )

            let first = Task { await viewModel.getDialogs(defaults: defaults) }
            await TestDefaults.waitForPause(of: client.gate)
            client.gate.resumeAll()
            await first.value

            let callsAfterFirstLoad = client.getDialogsCallCount
            await viewModel.getDialogs(refresh: true, defaults: defaults)

            #expect(client.getDialogsCallCount == callsAfterFirstLoad + 1)
        }

        @Test("Refresh без сети при загруженном списке не затирает диалоги ошибкой")
        func noConnectionRefreshKeepsLoadedDialogs() async throws {
            let defaults = TestDefaults.makeDefaultsService().0
            try defaults.saveUserInfo(UserResponse(id: 1, userName: "user"))
            let client = MockMessagesClient()
            client.mockedDialogs = [DialogResponse(id: 1, anotherUserName: "user2")]
            let viewModel = DialogsListScreen.ViewModel(
                isUITest: false,
                authHelper: MockAuthHelperForDefaultsService(),
                analytics: AnalyticsService(),
                makeDialogsClient: { _ in client }
            )

            await viewModel.getDialogs(defaults: defaults)
            #expect(viewModel.currentState == .ready(client.mockedDialogs))

            client.shouldThrowError = true
            await viewModel.getDialogs(refresh: true, defaults: defaults)

            #expect(viewModel.currentState == .ready(client.mockedDialogs))
            #expect(client.getDialogsCallCount == 2)
        }

        @Test("Refresh с произвольной ошибкой (например, таймаут) при загруженном списке сохраняет .ready")
        func genericErrorRefreshKeepsReadyState() async throws {
            let defaults = TestDefaults.makeDefaultsService().0
            try defaults.saveUserInfo(UserResponse(id: 1, userName: "user"))
            let client = MockMessagesClient()
            client.mockedDialogs = [DialogResponse(id: 1, anotherUserName: "user2")]
            let viewModel = DialogsListScreen.ViewModel(
                isUITest: false,
                authHelper: MockAuthHelperForDefaultsService(),
                analytics: AnalyticsService(),
                makeDialogsClient: { _ in client }
            )

            await viewModel.getDialogs(defaults: defaults)
            #expect(viewModel.currentState == .ready(client.mockedDialogs))

            client.shouldThrowError = true
            client.errorToThrow = MockMessagesClient.MockError.demoError
            await viewModel.getDialogs(refresh: true, defaults: defaults)

            #expect(viewModel.currentState == .ready(client.mockedDialogs))
            #expect(client.getDialogsCallCount == 2)
        }
    }
}

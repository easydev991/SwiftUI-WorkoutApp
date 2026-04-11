import Foundation
import SWModels
import Testing
@testable import WorkoutApp

private final class AnalyticsProviderSpy: AnalyticsProvider {
    private(set) var loggedEvents: [AnalyticsEvent] = []

    func log(event: AnalyticsEvent) {
        loggedEvents.append(event)
    }
}

struct AnalyticsServiceTests {
    @Test("fan-out отправляет событие во все провайдеры")
    @MainActor
    func log_sendsEventToAllProviders() {
        let spy1 = AnalyticsProviderSpy()
        let spy2 = AnalyticsProviderSpy()
        let service = AnalyticsService(providers: [spy1, spy2])

        let event = AnalyticsEvent.screenView(screen: .parksMap)
        service.log(event)

        #expect(spy1.loggedEvents.count == 1)
        #expect(spy2.loggedEvents.count == 1)
    }

    @Test("fan-out сохраняет порядок отправки")
    @MainActor
    func log_preservesOrder() {
        let spy1 = AnalyticsProviderSpy()
        let spy2 = AnalyticsProviderSpy()
        let service = AnalyticsService(providers: [spy1, spy2])

        let event = AnalyticsEvent.userAction(action: .login)
        service.log(event)

        #expect(spy1.loggedEvents.first?.actionName == "login")
        #expect(spy2.loggedEvents.first?.actionName == "login")
    }

    @Test("безопасная работа при пустом массиве провайдеров")
    @MainActor
    func log_doesNotThrowWithEmptyProviders() {
        let service = AnalyticsService(providers: [])
        service.log(AnalyticsEvent.screenView(screen: .root))
    }

    @Test("NoopAnalyticsProvider не падает на любых событиях")
    @MainActor
    func noopProvider_doesNotThrow() {
        let provider = NoopAnalyticsProvider()
        provider.log(event: AnalyticsEvent.screenView(screen: .login))
        provider.log(event: AnalyticsEvent.userAction(action: .login))
        provider.log(event: AnalyticsEvent.appError(kind: .loginFailed, error: AnalyticsServiceMockError.sample))
    }
}

private enum AnalyticsServiceMockError: Error {
    case sample
}

private extension AnalyticsEvent {
    var actionName: String {
        switch self {
        case let .screenView(screen, _):
            screen.rawValue
        case let .userAction(action):
            action.name
        case let .appError(kind, _):
            kind.rawValue
        }
    }
}

import Foundation
import Testing
@testable import WorkoutApp

private final class AnalyticsProviderSpy: AnalyticsProvider {
    private(set) var loggedEvents: [AnalyticsEvent] = []

    func log(event: AnalyticsEvent) {
        loggedEvents.append(event)
    }
}

struct AnalyticsServiceTests {
    @Test("безопасная работа при пустом провайдере (nil)")
    @MainActor
    func log_doesNotThrowWithEmptyProviders() {
        let service = AnalyticsService()
        service.log(AnalyticsEvent.screenView(screen: .root))
    }

    @Test("логирование вызывает провайдер")
    @MainActor
    func log_callsProvider() {
        let spy = AnalyticsProviderSpy()
        let service = AnalyticsService(provider: spy)

        let event = AnalyticsEvent.screenView(screen: .parksMap)
        service.log(event)

        #expect(spy.loggedEvents.count == 1)
        #expect(spy.loggedEvents.first?.actionName == "parks_map")
    }
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

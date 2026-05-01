import Foundation

struct AnalyticsService {
    private let providers: [any AnalyticsProvider]

    init(providers: [any AnalyticsProvider] = []) {
        self.providers = providers
    }

    func log(_ event: AnalyticsEvent) {
        for provider in providers {
            provider.log(event: event)
        }
    }
}

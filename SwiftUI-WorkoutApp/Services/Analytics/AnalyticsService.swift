import Foundation

struct AnalyticsService {
    private let provider: (any AnalyticsProvider)?

    init(provider: (any AnalyticsProvider)? = nil) {
        self.provider = provider
    }

    func log(_ event: AnalyticsEvent) {
        provider?.log(event: event)
    }
}

import Foundation

struct NoopAnalyticsProvider: AnalyticsProvider {
    func log(event _: AnalyticsEvent) {}
}

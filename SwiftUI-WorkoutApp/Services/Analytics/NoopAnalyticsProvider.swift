import Foundation
import SWModels

struct NoopAnalyticsProvider: AnalyticsProvider {
    func log(event _: AnalyticsEvent) {}
}

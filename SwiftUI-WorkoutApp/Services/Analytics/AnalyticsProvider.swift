import Foundation

protocol AnalyticsProvider {
    func log(event: AnalyticsEvent)
}

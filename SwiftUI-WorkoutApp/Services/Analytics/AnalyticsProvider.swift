import Foundation
import SWModels

protocol AnalyticsProvider {
    func log(event: AnalyticsEvent)
}

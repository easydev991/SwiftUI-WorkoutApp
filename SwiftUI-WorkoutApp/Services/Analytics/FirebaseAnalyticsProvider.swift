import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation
import SWModels

struct FirebaseAnalyticsProvider: AnalyticsProvider {
    func log(event: AnalyticsEvent) {
        switch event {
        case let .screenView(screen, source):
            var params: [String: Any] = ["screen": screen.rawValue]
            if let source {
                params["source"] = source.rawValue
            }
            Analytics.logEvent("screen_view", parameters: params)
        case let .userAction(action):
            var params: [String: Any] = ["action": action.name]
            switch action {
            case let .selectCountry(countryId, source):
                params["country_id"] = countryId
                params["source"] = source.rawValue
            case let .selectCity(cityId, source):
                params["city_id"] = cityId
                params["source"] = source.rawValue
            case let .sendFeedback(source):
                params["source"] = source.rawValue
            case let .reportPhoto(source):
                params["source"] = source.rawValue
            case let .reportComment(source):
                params["source"] = source.rawValue
            case let .selectParkFilterCity(cityId):
                params["city_id"] = cityId
            case let .selectParkFilterType(type):
                params["type"] = type
            case let .selectParkFilterSize(size):
                params["size"] = size
            case let .selectParkAnnotation(parkId):
                params["park_id"] = parkId
            case let .selectTheme(theme):
                params["theme"] = theme
            case let .selectAppIcon(iconName):
                params["icon_name"] = iconName
            case let .selectEventType(type):
                params["type"] = type
            default:
                break
            }
            Analytics.logEvent("user_action", parameters: params)
        case let .appError(kind, error):
            let nsError = error as NSError
            let params: [String: Any] = [
                "operation": kind.rawValue,
                "error_domain": nsError.domain,
                "error_code": nsError.code
            ]
            Analytics.logEvent("app_error", parameters: params)
            Crashlytics.crashlytics().record(error: nsError)
        }
    }
}

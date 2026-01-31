import Foundation

/// Модель для обратной связи по странам/городам
public enum LocationFeedback {
    case country
    case city

    public var subject: String {
        CommonFeedback.subject
    }

    public var body: String {
        let question = switch self {
        case .country:
            String(localized: .feedbackCountry)
        case .city:
            String(localized: .feedbackCity)
        }
        return """
        \(CommonFeedback.sysVersion)
        \(CommonFeedback.appVersion)
        \(question)
        \n
        """
    }
}

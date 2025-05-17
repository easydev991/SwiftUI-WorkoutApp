import Foundation

/// Модель для обратной связи по странам/городам
public enum LocationFeedback {
    case country
    case city

    public var subject: String { CommonFeedback.subject }

    public var body: String {
        let question: String = switch self {
        case .country:
            NSLocalizedString("Feedback.Country", bundle: .module, comment: "")
        case .city:
            NSLocalizedString("Feedback.City", bundle: .module, comment: "")
        }
        return """
        \(CommonFeedback.sysVersion)
        \(CommonFeedback.appVersion)
        \(question)
        \n
        """
    }
}

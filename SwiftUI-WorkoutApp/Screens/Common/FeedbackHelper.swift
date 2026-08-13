import SWDesignSystem
import SWModels
import SWUtils

@MainActor
extension ItemListScreen.Mode {
    /// Общий обработчик для кнопки "Написать нам" на экранах выбора страны/города.
    func sendFeedback(
        source: AnalyticsEvent.AppScreen,
        analytics: AnalyticsService,
        sender: FeedbackSender.Type = FeedbackSender.self
    ) {
        analytics.log(.userAction(action: .sendFeedback(source: source)))
        let (subject, body) = switch self {
        case .city: (LocationFeedback.city.subject, LocationFeedback.city.body)
        case .country: (LocationFeedback.country.subject, LocationFeedback.country.body)
        }
        sender.sendFeedback(
            subject: subject,
            messageBody: body,
            recipients: Constants.feedbackRecipient
        )
    }
}

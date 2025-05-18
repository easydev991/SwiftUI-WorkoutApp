import Foundation

public enum FeedbackSender {
    /// Открывает диплинк `mailto` для создания письма
    /// - Parameters:
    ///   - subject: Тема письма
    ///   - messageBody: Тело письма
    ///   - recipients: Получатели
    @MainActor
    public static func sendFeedback(
        subject: String,
        messageBody: String,
        recipients: [String]
    ) {
        guard !recipients.isEmpty else {
            assertionFailure("Не указан список получателей письма")
            return
        }
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "Feedback"
        let encodedBody = messageBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let encodedRecipients = recipients
            .map { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0 }
            .joined(separator: ",")
        let url = URL(string: "mailto:\(encodedRecipients)?subject=\(encodedSubject)&body=\(encodedBody)")
        URLOpener.open(url)
    }
}

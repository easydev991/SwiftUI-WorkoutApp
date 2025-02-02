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
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "Feedback"
        let encodedBody = messageBody.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        if let firstRecipient = recipients.first {
            let url = URL(string: "mailto:\(firstRecipient)?subject=\(encodedSubject)&body=\(encodedBody)")
            URLOpener.open(url)
        }
    }
}

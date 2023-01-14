import Foundation
import FeedbackSender

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    private let feedbackSender: FeedbackSender
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init() { feedbackSender = FeedbackSenderImp() }

    func feedbackAction() {
        feedbackSender.sendFeedback(
            subject: Feedback.subject,
            messageBody: Feedback.body,
            recipients: Constants.feedbackRecipient
        )
    }

    func deleteProfile(with defaults: DefaultsProtocol) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            try await APIService(with: defaults).deleteUser()
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension ProfileSettingsViewModel {
    enum Feedback {
        static let subject = "\(ProcessInfo.processInfo.processName): Обратная связь"
        static let body = """
            \(Feedback.sysVersion)
            \(Feedback.appVersion)
            \(Feedback.question)
            \n
        """
        private static let question = "Над чем нам стоит поработать?"
        private static let sysVersion = "iOS: \(ProcessInfo.processInfo.operatingSystemVersionString)"
        private static let appVersion = "App version: \(Constants.appVersion)"
    }
}

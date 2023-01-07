import Foundation
import FeedbackSender

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    private let feedbackSender: FeedbackSender
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init() {
        feedbackSender = FeedbackSenderImp()
    }

    func feedbackAction() {
        feedbackSender.sendFeedback(
            subject: Feedback.subject,
            messageBody: "\(Feedback.sysVersion)\n\(Feedback.appVersion)\n\n\(Feedback.question)\n",
            recipients: [Feedback.toEmail]
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
        static let toEmail = "info@workout.su"
        static let question = "Над чем нам стоит поработать?"
        static let sysVersion = "iOS: \(ProcessInfo.processInfo.operatingSystemVersionString)"
        static let appVersion = "App version: \(Constants.appVersion)"
    }
}

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
            subject: Constants.Feedback.subject,
            messageBody: "\(Constants.Feedback.sysVersion)\n\(Constants.Feedback.appVersion)\n\n\(Constants.Feedback.question)\n",
            recipients: [Constants.Feedback.toEmail]
        )
    }

    func deleteProfile(with defaults: DefaultsService) async {
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

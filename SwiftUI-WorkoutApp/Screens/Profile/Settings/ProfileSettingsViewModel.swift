import StoreKit

@MainActor
final class ProfileSettingsViewModel: ObservableObject {
    private let feedbackHelper: IFeedbackHelper
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init() {
        feedbackHelper = FeedbackService()
    }

    func feedbackAction() {
        feedbackHelper.sendFeedback()
    }

    func rateAppAction() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    func deleteProfile(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            try await APIService(with: defaults).deleteUser()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

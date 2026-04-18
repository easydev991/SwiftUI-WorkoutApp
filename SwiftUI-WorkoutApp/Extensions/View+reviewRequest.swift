import StoreKit
import SwiftUI

struct ReviewRequestModifier: ViewModifier {
    @EnvironmentObject private var reviewService: ReviewService
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content
            .task(id: reviewService.pendingRequest) {
                guard reviewService.pendingRequest else { return }
                try? await Task.sleep(for: .milliseconds(800))
                guard reviewService.pendingRequest else { return }
                requestReview()
                reviewService.markConsumed()
            }
    }
}

extension View {
    func reviewRequestHandling() -> some View {
        modifier(ReviewRequestModifier())
    }
}

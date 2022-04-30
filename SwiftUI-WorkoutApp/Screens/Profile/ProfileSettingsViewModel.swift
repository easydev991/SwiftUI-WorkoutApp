//
//  ProfileSettingsViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import StoreKit

final class ProfileSettingsViewModel: ObservableObject {
    private let feedbackHelper: IFeedbackHelper

    init() {
        feedbackHelper = FeedbackService()
    }

    func logoutAction(with userDefaults: UserDefaultsService) {
        userDefaults.isUserAuthorized = false
    }

    func feedbackAction() {
        feedbackHelper.sendFeedback()
    }

    func rateAppAction() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

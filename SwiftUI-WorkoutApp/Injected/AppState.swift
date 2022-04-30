//
//  AppState.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

final class AppState: ObservableObject {
    @AppStorage("isUserAuthorized") private(set) var isUserAuthorized = false
    @AppStorage("showWelcome") private(set) var showWelcome = true
    @Published var selectedTab = ContentView.Tab.events

    private let userDefaults: UserDefaultsService
    private let feedbackHelper: IFeedbackHelper

    init() {
        userDefaults = UserDefaultsService()
        feedbackHelper = FeedbackHelper()
    }

    func setIsUserAuth(_ auth: Bool) {
        userDefaults.isUserAuthorized = auth
    }

    func setShowWelcome(_ show: Bool) {
        userDefaults.showWelcome = show
    }

    func selectTab(_ tab: ContentView.Tab) {
        selectedTab = tab
    }

    func sendFeedback() {
        feedbackHelper.sendFeedback()
    }
}

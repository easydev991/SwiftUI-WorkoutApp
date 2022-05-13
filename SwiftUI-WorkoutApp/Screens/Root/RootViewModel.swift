//
//  RootViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

final class RootViewModel: ObservableObject {
    @Published var selectedTab = RootView.Tab.events

    func selectTab(_ tab: RootView.Tab) {
        selectedTab = tab
    }
}

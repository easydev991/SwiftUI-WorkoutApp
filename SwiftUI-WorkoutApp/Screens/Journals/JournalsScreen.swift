//
//  JournalsScreen.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct JournalsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
#warning("TODO: сверстать экран с дневниками")
            ZStack {
                if defaults.isAuthorized {
                    JournalGroupsList()
                } else {
                    IncognitoProfileView()
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(titleDisplayMode)
        }
    }
}

private extension JournalsScreen {
    var navigationTitle: String {
        defaults.isAuthorized
        ? "Дневники тренировок"
        : "Дневники"
    }

    var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        defaults.isAuthorized ? .inline : .large
    }
}

struct JournalsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsScreen()
            .environmentObject(DefaultsService())
    }
}

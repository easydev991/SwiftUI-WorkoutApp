//
//  JournalsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct JournalsView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = JournalsViewModel()

    var body: some View {
        NavigationView {
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать экран с дневниками")
            content
            .toolbar { addJournalButton }
            .navigationTitle(defaults.isAuthorized ? "Дневники тренировок" : "Дневники")
            .navigationBarTitleDisplayMode(defaults.isAuthorized ? .inline : .large)
        }
    }
}

private extension JournalsView {
    var content: some View {
        ZStack {
            if defaults.isAuthorized {
                EmptyContentView(mode: .journals)
            } else {
                IncognitoProfileView()
            }
        }
    }

    var addJournalButton: some View {
        NavigationLink(destination: Text("Создать дневник")) {
            Image(systemName: "plus")
        }
        .opacity(defaults.isAuthorized ? 1 : .zero)
    }
}

struct JournalsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsView()
            .environmentObject(UserDefaultsService())
    }
}

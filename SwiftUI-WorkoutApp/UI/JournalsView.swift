//
//  JournalsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct JournalsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            content()
                .navigationTitle("Дневники")
        }
    }
}

private extension JournalsView {
    func content() -> AnyView {
        switch appState.isUserAuthorized {
        case true:
#warning("Показать экран с дневниками или заглушку")
            return AnyView(Text("Дневники"))
        case false:
            return AnyView(IncognitoProfileView())
        }
    }
}

struct JournalsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsView()
            .environmentObject(AppState())
    }
}

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
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать экран с дневниками и заглушку")
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

//
//  MessagesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            content()
                .navigationTitle("Сообщения")
        }
    }
}

private extension MessagesView {
    func content() -> AnyView {
        switch appState.isUserAuthorized {
        case true:
#warning("Показать экран с сообщениями или заглушку")
            return AnyView(Text("Сообщения"))
        case false:
            return AnyView(IncognitoProfileView())
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            .environmentObject(AppState())
    }
}

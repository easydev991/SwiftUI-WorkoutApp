//
//  MessagesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = MessagesViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Сообщения")
        }
    }
}

private extension MessagesView {
    var content: AnyView {
        switch defaults.isAuthorized {
        case true:
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать экран с сообщениями и заглушку")
            return AnyView(Text("Сообщения"))
        case false:
            return AnyView(IncognitoProfileView())
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            .environmentObject(UserDefaultsService())
    }
}

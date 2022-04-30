//
//  MessagesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var viewModel = MessagesViewModel()

    var body: some View {
        NavigationView {
            content()
                .navigationTitle("Сообщения")
        }
    }
}

private extension MessagesView {
    func content() -> AnyView {
        switch userDefaults.isUserAuthorized {
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

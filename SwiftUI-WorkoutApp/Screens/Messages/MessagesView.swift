//
//  MessagesView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var defaults: DefaultsService
    @StateObject private var viewModel = MessagesViewModel()

    var body: some View {
        NavigationView {
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать экран с сообщениями")
            content
                .navigationTitle("Сообщения")
        }
    }
}

private extension MessagesView {
    var content: some View {
        ZStack {
            if defaults.isAuthorized {
                if !defaults.friendsIdsList.isEmpty {
                    EmptyContentView(mode: .messages)
                } else {
                    Text("Тут будут чаты с другими пользователями")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                IncognitoProfileView()
            }
        }
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
            .environmentObject(DefaultsService())
    }
}

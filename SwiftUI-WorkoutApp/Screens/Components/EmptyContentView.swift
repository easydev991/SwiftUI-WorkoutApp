//
//  EmptyContentView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import SwiftUI

struct EmptyContentView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    let mode: Mode

    var body: some View {
        content
            .padding()
    }
}

extension EmptyContentView {
    enum Mode {
        case events, journals, messages
        var text: (message: String, buttonTitle: String) {
            switch self {
            case .events:
                return ("Нет запланированных мероприятий", "Создать мероприятие")
            case .journals:
                return ("Дневников пока нет", "Создать дневник")
            case .messages:
                return ("Чатов пока нет", "Открыть список друзей")
            }
        }
    }
}

private extension EmptyContentView {
    var content: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(mode.text.message)
                .font(.title2)
                .multilineTextAlignment(.center)
            NavigationLink {
                switch mode {
                case .events:
                    CreateEventView(viewModel: .init(mode: .regular))
                case .journals:
                    Text("Создать дневник")
                case .messages:
                    UsersListView(mode: .friends(userID: defaults.mainUserID))
                        .navigationTitle("Друзья")
                }
            } label: {
                Text(mode.text.buttonTitle)
                    .roundedRectangleStyle()
            }
            Spacer()
        }
    }
}

struct EmptyContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyContentView(mode: .events)
            EmptyContentView(mode: .journals)
            EmptyContentView(mode: .messages)
        }
        .environmentObject(UserDefaultsService())
    }
}

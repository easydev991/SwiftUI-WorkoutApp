//
//  UserProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                Text("Вы вошли")
                    .padding()
                Button {
                    appState.isUserAuthorized = false
                } label: {
                    Text("Выйти")
                        .roundedRectangleStyle()
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .toolbar {
                Button {
                    appState.showWelcome = true
                } label: {
                    Text("Выход для разработчика")
                }
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
            .environmentObject(AppState())
    }
}

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
        VStack {
            Text("Вы вошли")
                .padding()
            NavigationLink {
                ProfileSettingsView()
            } label: {
                Label("Настройки", systemImage: "gear")
                    .roundedRectangleStyle()
            }
            .padding()
        }
        .toolbar {
            Button {
                appState.showWelcome = true
            } label: {
                Text("Выход для разработчика")
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

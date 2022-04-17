//
//  IncognitoProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct IncognitoProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                Text("Зарегистрируйтесь или выполните вход, чтобы иметь доступ ко всем возможностям")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                NavigationLink(destination: LoginView(), label: {
                    Label("Войти через email", systemImage: "envelope")
                        .roundedRectangleStyle()
                })
            }
            .padding()
            .navigationTitle("Профиль")
        }
    }
}

struct IncognitoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoProfileView()
            .environmentObject(AppState())
    }
}

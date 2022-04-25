//
//  ProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            content()
                .navigationTitle("Профиль")
        }
        .animation(.default, value: appState.isUserAuthorized)
        .ignoresSafeArea()
    }
}

private extension ProfileView {
    func content() -> AnyView {
        switch appState.isUserAuthorized {
        case true:
            return AnyView(PersonProfileView(model: .mockSingle))
        case false:
            return AnyView(IncognitoProfileView())
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
    }
}

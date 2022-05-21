//
//  ProfileScreen.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Профиль")
        }
        .ignoresSafeArea()
    }
}

private extension ProfileScreen {
    var content: some View {
        ZStack {
            if defaults.isAuthorized {
                UserDetailsView(userID: defaults.mainUserID)
            } else {
                IncognitoProfileView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
            .environmentObject(DefaultsService())
    }
}

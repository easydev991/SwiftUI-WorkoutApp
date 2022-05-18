//
//  ProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Профиль")
        }
        .ignoresSafeArea()
    }
}

private extension ProfileView {
    var content: some View {
        ZStack {
            if defaults.isAuthorized {
                UserProfileView(userID: defaults.mainUserID)
            } else {
                IncognitoProfileView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DefaultsService())
    }
}

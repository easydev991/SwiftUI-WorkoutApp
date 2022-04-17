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
        ZStack {
            if appState.isUserAuthorized {
                UserProfileView()
            } else {
                IncognitoProfileView()
            }
        }
        .animation(.default, value: appState.isUserAuthorized)
        .ignoresSafeArea()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
    }
}

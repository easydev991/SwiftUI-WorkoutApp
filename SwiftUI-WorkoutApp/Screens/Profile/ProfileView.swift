//
//  ProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            content
                .task(priority: .medium) {
                    await viewModel.checkFriendRequests(with: defaults)
                }
                .navigationTitle("Профиль")
        }
        .ignoresSafeArea()
    }
}

private extension ProfileView {
    var content: AnyView {
        if defaults.isAuthorized {
            return AnyView(UserProfileView(userID: defaults.mainUserID))
        } else {
            return AnyView(IncognitoProfileView())
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserDefaultsService())
    }
}

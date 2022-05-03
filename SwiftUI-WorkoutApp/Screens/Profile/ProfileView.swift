//
//  ProfileView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Профиль")
        }
        .ignoresSafeArea()
    }
}

private extension ProfileView {
    var content: AnyView {
        if userDefaults.isUserAuthorized {
            return AnyView(PersonProfileView(viewModel: .init(userID: userDefaults.mainUserID)))
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

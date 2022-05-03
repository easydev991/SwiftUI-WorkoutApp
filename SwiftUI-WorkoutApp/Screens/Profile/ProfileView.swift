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
        }
        .animation(.default, value: userDefaults.isUserAuthorized)
        .ignoresSafeArea()
    }
}

private extension ProfileView {
    var content: AnyView {
        switch userDefaults.isUserAuthorized {
        case true:
            return AnyView(PersonProfileView(user: .mockMain))
        case false:
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

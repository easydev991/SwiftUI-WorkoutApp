//
//  WelcomeAuthView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct WelcomeAuthView: View {
    @EnvironmentObject private var defaults: UserDefaultsService
    @StateObject private var viewModel = WelcomeAuthViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                logo
                buttonsView
            }
            .ignoresSafeArea()
        }
        .transition(
            .move(edge: .leading)
            .combined(with: .scale)
            .combined(with: .opacity)
        )
    }
}

private extension WelcomeAuthView {
    var logo: some View {
        Image("login_logo")
    }

    var buttonsView: some View {
        VStack(spacing: 16) {
            Spacer()
            registerButton
            loginButton
            skipLoginButton
        }
        .padding()
    }

    var registerButton: some View {
        NavigationLink(destination: EditAccountView()) {
            Label("Создать аккаунт", systemImage: "person.badge.plus")
                .welcomeLoginButtonTitle()
        }
    }

    var loginButton: some View {
        NavigationLink(destination: LoginView()) {
            Label("Войти через email", systemImage: "envelope")
                .welcomeLoginButtonTitle()
        }
    }

    var skipLoginButton: some View {
        Button(action: defaults.setWelcomeShown) {
            Text("Пропустить")
                .frame(height: 48)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct WelcomeAuthView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeAuthView()
            .environmentObject(UserDefaultsService())
    }
}

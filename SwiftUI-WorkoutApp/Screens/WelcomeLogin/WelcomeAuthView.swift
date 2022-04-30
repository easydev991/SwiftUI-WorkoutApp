//
//  WelcomeAuthView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct WelcomeAuthView: View {
    @EnvironmentObject private var userDefaults: UserDefaultsService
    @StateObject private var viewModel = WelcomeAuthViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                Image("login_logo")
                buttonsView()
            }
            .ignoresSafeArea()
        }
    }
}

private extension WelcomeAuthView {
    func buttonsView() -> some View {
        VStack(spacing: 16) {
            Spacer()
            registerButton()
            loginButton()
            skipLoginButton()
        }
        .padding()
    }

    func registerButton() -> some View {
        NavigationLink(destination: EditAccountView()) {
            Label("Создать аккаунт", systemImage: "person.badge.plus")
                .welcomeLoginButtonTitle()
        }
    }

    func loginButton() -> some View {
        NavigationLink(destination: LoginView()) {
            Label("Войти через email", systemImage: "envelope")
                .welcomeLoginButtonTitle()
        }
    }

    func skipLoginButton() -> some View {
        Button {
            userDefaults.showWelcome = false
        } label: {
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

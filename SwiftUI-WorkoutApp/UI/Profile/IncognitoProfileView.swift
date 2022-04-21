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
        VStack(spacing: 16) {
            incognitoInformer()
            registerButton()
            loginButton()
        }
        .padding()
    }
}

private extension IncognitoProfileView {
    func incognitoInformer() -> some View {
        Text("Зарегистрируйтесь или выполните вход, чтобы иметь доступ ко всем возможностям")
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding()
    }

    func registerButton() -> some View {
        NavigationLink(destination: EditAccountView()) {
            Label("Создать аккаунт", systemImage: "person.badge.plus")
                .roundedRectangleStyle()
        }
    }

    func loginButton() -> some View {
        NavigationLink(destination: LoginView(), label: {
            Label("Войти через email", systemImage: "envelope")
                .roundedRectangleStyle()
        })
    }
}

struct IncognitoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoProfileView()
            .environmentObject(AppState())
    }
}

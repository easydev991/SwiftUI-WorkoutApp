import SwiftUI

/// Приветственный экран для регистрации/авторизации
struct WelcomeView: View {
    @EnvironmentObject private var defaults: DefaultsService

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

private extension WelcomeView {
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
        NavigationLink(destination: AccountInfoView()) {
            Label("Создать аккаунт", systemImage: "person.badge.plus")
                .welcomeButtonTitle()
        }
    }

    var loginButton: some View {
        NavigationLink(destination: LoginView()) {
            Label("Войти через email", systemImage: "envelope")
                .welcomeButtonTitle()
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
        WelcomeView()
            .environmentObject(DefaultsService())
    }
}

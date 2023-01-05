import SwiftUI

/// Приветственный экран для регистрации/авторизации
struct WelcomeView: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                Image("login_logo")
                buttonsView
            }
            .ignoresSafeArea()
        }
        .navigationViewStyle(.stack)
        .opacity(defaults.showWelcome ? 1 : 0)
        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)).combined(with: .scale))
    }
}

private extension WelcomeView {
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
        NavigationLink(destination: AccountInfoView(mode: .create)) {
            Label("Регистрация", systemImage: "person.badge.plus")
                .welcomeButtonTitle()
        }
    }

    var loginButton: some View {
        NavigationLink(destination: LoginView()) {
            Label("Авторизация", systemImage: "arrow.forward.circle")
                .welcomeButtonTitle()
        }
    }

    var skipLoginButton: some View {
        Button { defaults.setWelcomeShown() } label: {
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

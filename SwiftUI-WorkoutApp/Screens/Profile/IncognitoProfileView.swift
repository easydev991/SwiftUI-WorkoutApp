import SwiftUI

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            incognitoInformer
            registerButton
            loginButton
        }
        .padding()
    }
}

private extension IncognitoProfileView {
    var incognitoInformer: some View {
        Text("Зарегистрируйтесь или выполните вход, чтобы иметь доступ ко всем возможностям")
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding()
    }

    var registerButton: some View {
        NavigationLink {
            AccountInfoView()
                .navigationTitle("Регистрация")
        } label: {
            Label("Создать аккаунт", systemImage: "person.badge.plus")
                .roundedRectangleStyle()
        }
    }

    var loginButton: some View {
        NavigationLink(destination: LoginView()) {
            Label("Войти через email", systemImage: "envelope")
                .roundedRectangleStyle()
        }
    }
}

struct IncognitoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoProfileView()
    }
}

import SWDesignSystem
import SwiftUI

struct IncognitoUserButton: View {
    @State private var isLinkActive = false
    var mode = IncognitoUserButton.Mode.authorize

    var body: some View {
        NavigationLink(mode.title, destination: mode.destination, isActive: $isLinkActive)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
            .accessibilityIdentifier("authorizeButton")
    }
}

extension IncognitoUserButton {
    enum Mode {
        /// Регистрация
        ///
        /// Пока недоступна
        case register
        /// Авторизация
        case authorize
    }
}

private extension IncognitoUserButton.Mode {
    var title: LocalizedStringKey {
        switch self {
        case .register:
            "Регистрация"
        case .authorize:
            "Авторизация"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .register: EmptyView()
        case .authorize: LoginView()
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        VStack(spacing: 16) {
            IncognitoUserButton(mode: .authorize)
            IncognitoUserButton(mode: .register)
        }
        .padding(.horizontal)
    }
    .previewDisplayName("Инкогнито экран")
}
#endif

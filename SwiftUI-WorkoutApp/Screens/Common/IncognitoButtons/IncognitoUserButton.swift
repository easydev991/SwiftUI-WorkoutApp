import DesignSystem
import SwiftUI

struct IncognitoUserButton: View {
    @State private var isLinkActive = false
    let mode: IncognitoUserButton.Mode

    var body: some View {
        NavigationLink(mode.title, destination: mode.destination, isActive: $isLinkActive)
            .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
    }
}

extension IncognitoUserButton {
    enum Mode {
        /// Регистрация
        case register
        /// Авторизация
        case authorize
    }
}

private extension IncognitoUserButton.Mode {
    var title: String {
        switch self {
        case .register:
            return "Регистрация"
        case .authorize:
            return "Авторизация"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .register: AccountInfoView(mode: .create)
        case .authorize: LoginView()
        }
    }
}

#if DEBUG
struct IncognitoUserButton_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack(spacing: 16) {
                IncognitoUserButton(mode: .authorize)
                IncognitoUserButton(mode: .register)
            }
            .padding(.horizontal)
        }
        .previewDisplayName("Инкогнито экран")
    }
}
#endif

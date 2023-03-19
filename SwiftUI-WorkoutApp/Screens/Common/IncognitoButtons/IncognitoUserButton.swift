import DesignSystem
import SwiftUI

struct IncognitoUserButton: View {
    @State private var isLinkActive = false
    let mode: IncognitoUserButton.Mode

    var body: some View {
        NavigationLink(mode.title, destination: mode.destination, isActive: $isLinkActive)
            .buttonStyle(SWButtonStyle(mode: .filled))
    }
}

extension IncognitoUserButton {
    #warning("Убрать inForm при редизайне")
    enum Mode {
        /// Регистрация
        ///
        /// `inForm = true` - отображаем кнопку внутри формы (`Form`), иначе - вне формы
        case register(inForm: Bool)
        /// Авторизация
        case authorize(inForm: Bool)
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
                IncognitoUserButton(mode: .authorize(inForm: false))
                IncognitoUserButton(mode: .register(inForm: false))
            }
            .padding(.horizontal)
        }
        .previewDisplayName("Инкогнито экран")
    }
}
#endif

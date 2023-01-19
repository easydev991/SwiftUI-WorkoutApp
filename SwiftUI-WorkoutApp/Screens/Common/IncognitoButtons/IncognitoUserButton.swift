import SwiftUI

struct IncognitoUserButton: View {
    let mode: IncognitoUserButton.Mode

    var body: some View {
        NavigationLink(destination: mode.destination) {
            mode.label
        }
    }
}

extension IncognitoUserButton {
    enum Mode {
        /// Регистрация
        ///
        /// `inForm = true` - отображаем кнопку внутри формы (`Form`), иначе - вне формы
        case register(inForm: Bool)
        /// Авторизация
        case authorize(inForm: Bool)
        
        @ViewBuilder
        var label: some View {
            switch self {
            case let .register(inForm), let .authorize(inForm):
                if inForm {
                    Label(title, systemImage: systemImageName)
                } else {
                    Label(title, systemImage: systemImageName)
                        .roundedStyle()
                }
            }
        }
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

    var systemImageName: String {
        switch self {
        case .register:
            return "person.badge.plus"
        case .authorize:
            return "arrow.forward.circle"
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
        VStack(spacing: 16) {
            IncognitoUserButton(mode: .authorize(inForm: true))
            IncognitoUserButton(mode: .register(inForm: true))
            IncognitoUserButton(mode: .authorize(inForm: false))
            IncognitoUserButton(mode: .register(inForm: false))
        }
        .padding()
        .previewDisplayName("Инкогнито экран")
    }
}
#endif

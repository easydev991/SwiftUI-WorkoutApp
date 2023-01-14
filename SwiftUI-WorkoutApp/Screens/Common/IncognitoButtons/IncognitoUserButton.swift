import SwiftUI

struct IncognitoUserButton: View {
    let mode: IncognitoUserButton.Mode

    var body: some View {
        NavigationLink(destination: mode.destination) {
            mode.label
                .roundedStyle()
        }
    }
}

extension IncognitoUserButton {
    enum Mode { case register, authorize }
}

private extension IncognitoUserButton.Mode {
    @ViewBuilder
    var destination: some View {
        switch self {
        case .register: AccountInfoView(mode: .create)
        case .authorize: LoginView()
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .register:
            Label("Регистрация", systemImage: "person.badge.plus")
        case .authorize:
            Label("Авторизация", systemImage: "arrow.forward.circle")
        }
    }
}

#if DEBUG
struct IncognitoUserButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            IncognitoUserButton(mode: .authorize)
            IncognitoUserButton(mode: .register)
        }
        .padding()
        .previewDisplayName("Инкогнито экран")
    }
}
#endif

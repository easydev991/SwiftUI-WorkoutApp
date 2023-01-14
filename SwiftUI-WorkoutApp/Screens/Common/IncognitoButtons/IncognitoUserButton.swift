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
        case register(source: IncognitoButtonLabelModifier.Source)
        case authorize(source: IncognitoButtonLabelModifier.Source)
    }
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
        case let .register(source):
            Label("Регистрация", systemImage: "person.badge.plus")
                .incognitoButtonStyle(source: source)
        case let .authorize(source):
            Label("Авторизация", systemImage: "arrow.forward.circle")
                .incognitoButtonStyle(source: source)
        }
    }
}

#if DEBUG
struct IncognitoUserButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 16) {
                IncognitoUserButton(mode: .authorize(source: .welcomeView))
                IncognitoUserButton(mode: .register(source: .welcomeView))
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Приветственный экран")
            VStack(spacing: 16) {
                IncognitoUserButton(mode: .authorize(source: .incognitoView))
                IncognitoUserButton(mode: .register(source: .incognitoView))
            }
            .previewDisplayName("Инкогнито экран")
        }
        .padding()
    }
}
#endif

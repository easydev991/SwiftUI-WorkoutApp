import SwiftUI

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            incognitoInformer
            registerButton
            loginButton
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                IncognitoNavbarInfoButton()
            }
        }
        .padding()
    }
}

private extension IncognitoProfileView {
    var incognitoInformer: some View {
        Text(Constants.incognitoInfoText)
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding()
    }

    var registerButton: some View {
        IncognitoUserButton(mode: .register(source: .incognitoView))
    }

    var loginButton: some View {
        IncognitoUserButton(mode: .authorize(source: .incognitoView))
    }
}

#if DEBUG
struct IncognitoProfileView_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoProfileView()
            .previewLayout(.sizeThatFits)
    }
}
#endif

import SwiftUI

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            incognitoInformer
            createAccountButton
            IncognitoUserButton(mode: .authorize(inForm: false))
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

    var createAccountButton: some View {
        Link(destination: Constants.accountCreationURL) {
            IncognitoUserButton.Mode.register(inForm: false).label
        }
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

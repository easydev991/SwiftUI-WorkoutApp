import SwiftUI
import SWModels

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            authInvitation
            IncognitoUserButton(mode: .authorize(inForm: false))
            registrationInfo
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
    var authInvitation: some View {
        Text(Constants.authInvitationText)
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    var registrationInfo: some View {
        Text(Constants.registrationInfoText)
            .font(.subheadline)
            .multilineTextAlignment(.center)
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

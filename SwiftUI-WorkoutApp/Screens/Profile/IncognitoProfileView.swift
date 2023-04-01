import DesignSystem
import SwiftUI
import SWModels

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            authInvitation
            IncognitoUserButton(mode: .authorize)
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
            .multilineTextAlignment(.center)
            .foregroundColor(.swMainText)
            .padding(.bottom, 6)
    }

    var registrationInfo: some View {
        Text(Constants.registrationInfoText)
            .font(.footnote.weight(.medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.swMainText)
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

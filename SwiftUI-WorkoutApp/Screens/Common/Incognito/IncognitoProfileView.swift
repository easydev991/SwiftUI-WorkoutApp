import DesignSystem
import SwiftUI
import SWModels

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    var body: some View {
        VStack(spacing: 16) {
            authInvitation
            IncognitoUserButton()
            registrationInfo
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.swBackground)
    }
}

private extension IncognitoProfileView {
    var authInvitation: some View {
        Text(.init(Constants.authInvitationText))
            .multilineTextAlignment(.center)
            .foregroundColor(.swMainText)
            .padding(.bottom, 6)
    }

    var registrationInfo: some View {
        Text(.init(Constants.registrationInfoText))
            .font(.footnote.weight(.medium))
            .multilineTextAlignment(.center)
            .foregroundColor(.swMainText)
    }
}

#if DEBUG
#Preview {
    IncognitoProfileView()
        .previewLayout(.sizeThatFits)
}
#endif

import SWDesignSystem
import SwiftUI
import SWModels

/// Заглушка для неавторизованного пользователя
struct IncognitoProfileView: View {
    @State private var showAuthScreen = false

    var body: some View {
        VStack(spacing: 16) {
            authInvitation
            goToLoginButton
            registrationInfo
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.swBackground)
        .sheet(isPresented: $showAuthScreen) {
            ContentInSheet(title: "Авторизация") {
                LoginScreen()
            }
        }
    }
}

private extension IncognitoProfileView {
    var authInvitation: some View {
        Text(.init(Constants.authInvitationText))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.swMainText)
            .padding(.bottom, 6)
    }

    var goToLoginButton: some View {
        Button("Авторизация") {
            showAuthScreen = true
        }
        .buttonStyle(SWButtonStyle(mode: .filled, size: .large))
        .accessibilityIdentifier("authorizeButton")
    }

    var registrationInfo: some View {
        Text(.init(Constants.registrationInfoText))
            .font(.footnote.weight(.medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.swMainText)
    }
}

#if DEBUG
#Preview {
    IncognitoProfileView()
}
#endif

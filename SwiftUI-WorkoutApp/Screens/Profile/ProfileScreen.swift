import SWDesignSystem
import SwiftUI

/// Экран профиля пользователя
struct ProfileScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    UserDetailsView(for: defaults.mainUserInfo)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    IncognitoProfileView()
                }
            }
            .background(Color.swBackground)
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(defaults.isAuthorized ? .inline : .large)
        }
        .navigationViewStyle(.stack)
    }
}

#if DEBUG
#Preview {
    ProfileScreen()
        .environmentObject(DefaultsService())
}
#endif

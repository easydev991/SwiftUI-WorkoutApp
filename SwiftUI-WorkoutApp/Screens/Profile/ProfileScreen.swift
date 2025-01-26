import SWDesignSystem
import SwiftUI

/// Экран профиля пользователя
struct ProfileScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    MainUserProfileScreen()
                        .navigationBarTitleDisplayMode(.inline)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    IncognitoProfileView()
                        .navigationBarTitleDisplayMode(.large)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring, value: defaults.isAuthorized)
            .background(Color.swBackground)
            .navigationTitle("Профиль")
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

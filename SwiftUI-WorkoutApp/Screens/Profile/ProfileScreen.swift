import SwiftUI

/// Экран профиля пользователя
struct ProfileScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    UserDetailsView(for: defaults.mainUserInfo)
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    IncognitoProfileView()
                        .navigationTitle("Профиль")
                        .navigationBarTitleDisplayMode(.large)
                }
            }
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

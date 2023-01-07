import SwiftUI

/// Экран профиля пользователя
struct ProfileScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    UserDetailsView(for: defaults.mainUserInfo)
                } else {
                    IncognitoProfileView()
                }
            }
            .navigationTitle("Профиль")
        }
        .navigationViewStyle(.stack)
        .ignoresSafeArea()
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
            .environmentObject(DefaultsService())
    }
}
#endif

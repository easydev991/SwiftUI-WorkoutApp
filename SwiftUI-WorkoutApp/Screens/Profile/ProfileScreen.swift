import SwiftUI

/// Экран профиля пользователя
struct ProfileScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    UserDetailsView(userID: defaults.mainUserID)
                } else {
                    IncognitoProfileView()
                }
            }
            .navigationTitle("Профиль")
        }
        .ignoresSafeArea()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
            .environmentObject(DefaultsService())
    }
}

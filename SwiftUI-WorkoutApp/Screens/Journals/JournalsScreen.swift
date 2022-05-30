import SwiftUI

/// Экран с дневниками пользователя
struct JournalsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    JournalsList(for: defaults.mainUserID)
                } else {
                    IncognitoProfileView()
                }
            }
            .navigationTitle(defaults.isAuthorized ? "Дневники тренировок" : "Дневники")
            .navigationBarTitleDisplayMode(defaults.isAuthorized ? .inline : .large)
        }
    }
}

struct JournalsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsScreen()
            .environmentObject(DefaultsService())
    }
}

import SwiftUI

/// Экран с дневниками пользователя
struct JournalsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    JournalsListView(for: defaults.mainUserID)
                } else {
                    IncognitoProfileView()
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(titleDisplayMode)
        }
        .navigationViewStyle(.stack)
    }
}

private extension JournalsScreen {
    var navigationTitle: String {
        defaults.isAuthorized
        ? "Дневники тренировок"
        : "Дневники"
    }

    var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        defaults.isAuthorized ? .inline : .large
    }
}

struct JournalsView_Previews: PreviewProvider {
    static var previews: some View {
        JournalsScreen()
            .environmentObject(DefaultsService())
    }
}

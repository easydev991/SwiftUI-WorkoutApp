import SwiftUI

/// Экран с диалогами
struct DialogsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            ZStack {
                if defaults.isAuthorized {
                    DialogListView()
                } else {
                    IncognitoProfileView()
                }
            }
            .navigationTitle("Сообщения")
            .navigationBarTitleDisplayMode(titleDisplayMode)
        }
    }
}

private extension DialogsScreen {
    var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        defaults.isAuthorized ? .inline : .large
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        DialogsScreen()
            .environmentObject(DefaultsService())
    }
}

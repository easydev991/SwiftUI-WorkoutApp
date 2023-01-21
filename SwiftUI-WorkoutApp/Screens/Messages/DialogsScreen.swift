import SwiftUI

/// Экран с диалогами
struct DialogsScreen: View {
    @EnvironmentObject private var defaults: DefaultsService

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Сообщения")
                .navigationBarTitleDisplayMode(titleDisplayMode)
        }
        .navigationViewStyle(.stack)
    }
}

private extension DialogsScreen {
    var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        defaults.isAuthorized ? .inline : .large
    }

    @ViewBuilder
    var contentView: some View {
        if defaults.isAuthorized {
            DialogListView()
        } else {
            IncognitoProfileView()
        }
    }
}

#if DEBUG
struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        DialogsScreen()
            .environmentObject(DefaultsService())
    }
}
#endif

import SWDesignSystem
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
            .background(Color.swBackground)
            .transaction { $0.animation = nil }
            .navigationTitle("Сообщения")
            .navigationBarTitleDisplayMode(defaults.isAuthorized ? .inline : .large)
        }
        .navigationViewStyle(.stack)
    }
}

#if DEBUG
#Preview {
    DialogsScreen()
        .environmentObject(DefaultsService())
}
#endif

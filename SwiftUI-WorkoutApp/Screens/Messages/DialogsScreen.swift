import SWDesignSystem
import SwiftUI

/// Экран "Сообщения"
struct DialogsScreen: View {
    @Environment(\.userFlags) private var userFlags

    var body: some View {
        NavigationView {
            ZStack {
                if userFlags.isAuthorized {
                    DialogsListScreen()
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    IncognitoProfileView()
                        .navigationBarTitleDisplayMode(.large)
                }
            }
            .background(Color.swBackground)
            .transaction { $0.animation = nil }
            .navigationTitle("Сообщения")
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

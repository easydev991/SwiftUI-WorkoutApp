import DesignSystem
import SwiftUI

/// Кнопка с навигацией на экран настроек `ProfileSettingsView`
struct IncognitoNavbarInfoButton: View {
    var body: some View {
        NavigationLink(destination: ProfileSettingsView(mode: .incognito)) {
            Image(systemName: Icons.Regular.info.rawValue)
        }
    }
}

#if DEBUG
#Preview {
    IncognitoNavbarInfoButton()
}
#endif

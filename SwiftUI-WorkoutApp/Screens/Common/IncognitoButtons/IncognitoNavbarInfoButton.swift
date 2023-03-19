import DesignSystem
import SwiftUI

/// Кнопка с навигацией на экран настроек `ProfileSettingsView`
struct IncognitoNavbarInfoButton: View {
    var body: some View {
        NavigationLink(destination: ProfileSettingsView(mode: .incognito)) {
            Image(systemName: Icons.Button.info.rawValue)
        }
    }
}

#if DEBUG
struct IncognitoNavbarInfoButton_Previews: PreviewProvider {
    static var previews: some View {
        IncognitoNavbarInfoButton()
    }
}
#endif

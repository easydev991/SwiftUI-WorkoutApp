import SwiftUI

extension EnvironmentValues {
    /// `true` - есть подключение, `false` - нет подключения
    @Entry var isNetworkConnected = false
}

extension View {
    func networkStatus(_ isOnline: Bool) -> some View {
        environment(\.isNetworkConnected, isOnline)
    }
}

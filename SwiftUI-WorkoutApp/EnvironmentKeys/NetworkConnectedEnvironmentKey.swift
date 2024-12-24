import SwiftUI

/// Ключ для получения состояния подключения к интернету
struct NetworkConnectedEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// `true` - есть подключение, `false` - нет подключения
    var networkConnected: Bool {
        get { self[NetworkConnectedEnvironmentKey.self] }
        set { self[NetworkConnectedEnvironmentKey.self] = newValue }
    }
}

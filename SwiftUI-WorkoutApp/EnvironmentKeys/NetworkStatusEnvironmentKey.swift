import SwiftUI

/// Ключ для получения состояния подключения к интернету
struct NetworkStatusEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// `true` - есть подключение, `false` - нет подключения
    var isNetworkConnected: Bool {
        get { self[NetworkStatusEnvironmentKey.self] }
        set { self[NetworkStatusEnvironmentKey.self] = newValue }
    }
}

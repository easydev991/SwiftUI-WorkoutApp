import SwiftUI
import SWModels

/// Ключ для получения "флагов" пользователя
struct UserFlagsEnvironmentKey: EnvironmentKey {
    static let defaultValue = UserFlags.defaultValue
}

extension EnvironmentValues {
    /// Флаги пользователя
    var userFlags: UserFlags {
        get { self[UserFlagsEnvironmentKey.self] }
        set { self[UserFlagsEnvironmentKey.self] = newValue }
    }
}

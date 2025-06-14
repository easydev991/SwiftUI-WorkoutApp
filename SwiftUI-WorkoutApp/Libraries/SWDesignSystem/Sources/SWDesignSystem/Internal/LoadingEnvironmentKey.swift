import Foundation
import SwiftUI

struct LoadingEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// `true` - находимся в состоянии загрузки,  `false` - обычное состояние
    var isLoading: Bool {
        get { self[LoadingEnvironmentKey.self] }
        set { self[LoadingEnvironmentKey.self] = newValue }
    }
}

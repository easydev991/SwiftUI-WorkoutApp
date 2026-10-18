import Foundation
import SWKeychain
@testable import WorkoutApp

/// Общие хелперы сьютов, работающих через UserDefaults.standard
enum TestDefaults {
    /// Чистит весь UserDefaults.standard — @AppStorage в DefaultsService пишут туда напрямую
    @MainActor
    static func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
    }

    /// Чистый DefaultsService с моком authHelper
    @MainActor
    static func makeDefaultsService(authData: AuthData? = nil) -> (DefaultsService, MockAuthHelperForDefaultsService) {
        clearUserDefaults()
        let mockAuthHelper = MockAuthHelperForDefaultsService(authData: authData)
        let defaultsService = DefaultsService(authHelper: mockAuthHelper)
        return (defaultsService, mockAuthHelper)
    }

    /// Ждёт события «мок заблокировался в паузе» — детерминированная замена таймингов
    @MainActor
    static func waitForPause(of gate: PauseGate) async {
        await withCheckedContinuation { continuation in
            gate.onPaused = { continuation.resume() }
        }
    }
}

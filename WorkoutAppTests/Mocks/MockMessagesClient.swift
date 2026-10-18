import Foundation
import SWModels
import SWNetworkClient

/// Мок `MessagesClient`: управляемый результат, пауза до сигнала и подсчёт вызовов
@MainActor
final class MockMessagesClient: MessagesClient {
    var mockedDialogs: [DialogResponse] = []
    /// Бросать ошибку из `getDialogs` — для тестов обработки ошибок; по умолчанию `ClientError.noConnection`
    var shouldThrowError = false
    /// Какую ошибку бросать при `shouldThrowError = true` — например, произвольную, не только сетевую
    var errorToThrow: Error = MockMessagesClient.MockError.demoError
    var getDialogsCallCount = 0
    /// Гейт паузы: `pauseFirstCalls`, `onPaused`, `resumeAll()` — см. `PauseGate`
    let gate = PauseGate()

    func getDialogs() async throws -> [DialogResponse] {
        getDialogsCallCount += 1
        await gate.waitIfPaused()
        if shouldThrowError {
            throw errorToThrow
        }
        return mockedDialogs
    }

    func getMessages(for _: Int) async throws -> [MessageResponse] {
        throw MockMessagesClient.MockError.demoError
    }

    func sendMessage(_: String, to _: Int) async throws {
        throw MockMessagesClient.MockError.demoError
    }

    func markAsRead(from _: Int) async throws {
        throw MockMessagesClient.MockError.demoError
    }

    func deleteDialog(_: Int) async throws {
        throw MockMessagesClient.MockError.demoError
    }
}

extension MockMessagesClient {
    /// Ошибка для тестирования
    enum MockError: Error {
        case demoError
    }
}

import Foundation
import SWModels
import SWNetworkClient

/// Мок `ProfileClient`: управляемый результат, пауза до сигнала и подсчёт вызовов
@MainActor
final class MockSocialUpdatesClient: ProfileClient {
    var shouldThrowError = false
    var errorToThrow: Error = MockSocialUpdatesClient.MockError.demoError
    var mockedUser = UserResponse(id: 1, userName: "user")
    var getSocialUpdatesCallCount = 0
    /// Гейт паузы: `pauseFirstCalls`, `onPaused`, `resumeAll()` — см. `PauseGate`
    let gate = PauseGate()

    func getUserById(_: Int) async throws -> UserResponse {
        throw MockSocialUpdatesClient.MockError.demoError
    }

    func editUser(_: Int, model _: MainUserForm) async throws -> UserResponse {
        throw MockSocialUpdatesClient.MockError.demoError
    }

    func changePassword(current _: String, new _: String) async throws {
        throw MockSocialUpdatesClient.MockError.demoError
    }

    func getSocialUpdates(userId _: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    ) {
        getSocialUpdatesCallCount += 1
        await gate.waitIfPaused()
        if shouldThrowError {
            throw errorToThrow
        }
        return (user: mockedUser, friends: [], friendRequests: [], blacklist: [])
    }
}

extension MockSocialUpdatesClient {
    /// Ошибка для тестирования
    enum MockError: Error {
        case demoError
    }
}

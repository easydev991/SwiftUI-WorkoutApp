import Foundation
import SWModels

/// Протокол для работы с профилем пользователя
public protocol ProfileClient: Sendable {
    /// Запрашивает данные пользователя по `id`
    ///
    /// В случае успеха сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameter userId: `id` пользователя
    /// - Returns: вся информация о пользователе
    func getUserById(_ userId: Int) async throws -> UserResponse

    /// Изменяет данные пользователя
    /// - Parameters:
    ///   - id: `id` пользователя
    ///   - model: данные для изменения
    /// - Returns: Актуальные данные пользователя
    func editUser(_ id: Int, model: MainUserForm) async throws -> UserResponse

    /// Меняет текущий пароль на новый
    /// - Parameters:
    ///   - current: текущий пароль
    ///   - new: новый пароль
    func changePassword(current: String, new: String) async throws

    /// Запрашивает обновления для пользователя и его списков: друзья, заявки, черный список
    ///
    /// - Вызывается при авторизации и при `scenePhase = active`
    /// - Список чатов не обновляет (для этого `DialogsViewModel`)
    /// - Parameter userId: Идентификатор основного пользователя
    /// - Returns: Список друзей, заявок в друзья и черный список
    func getSocialUpdates(userId: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    )
}

extension SWClient: ProfileClient {
    public func getSocialUpdates(userId: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    ) {
        async let user = getUserById(userId)
        async let friendsForUser = getFriendsForUser(id: userId)
        async let friendRequests = getFriendRequests()
        async let blacklist = getBlacklist()
        return try await (user, friendsForUser, friendRequests, blacklist)
    }

    public func getUserById(_ userId: Int) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userId)
        return try await makeResult(for: endpoint)
    }

    public func editUser(_ id: Int, model: MainUserForm) async throws -> UserResponse {
        let endpoint = Endpoint.editUser(id: id, form: model)
        return try await makeResult(for: endpoint)
    }

    public func changePassword(current: String, new: String) async throws {
        let endpoint = Endpoint.changePassword(currentPass: current, newPass: new)
        try await makeStatus(for: endpoint)
    }
}

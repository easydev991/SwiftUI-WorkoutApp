import Foundation
import SWModels

/// Протокол для работы с друзьями и социальными функциями
public protocol FriendsClient: Sendable {
    /// Загружает список друзей для выбранного пользователя
    ///
    /// Для главного пользователя в случае успеха сохраняет идентификаторы друзей в `defaults`
    /// - Parameter id: `id` пользователя
    /// - Returns: Список друзей выбранного пользователя
    func getFriendsForUser(id: Int) async throws -> [UserResponse]

    /// Загружает список заявок на добавление в друзья
    /// - Returns: Список заявок в друзья
    func getFriendRequests() async throws -> [UserResponse]

    /// Отвечает на заявку для добавления в друзья
    ///
    /// В случае успеха запрашивает список заявок повторно, а если запрос одобрен - дополнительно запрашивает список друзей
    /// - Parameters:
    ///   - userId: `id` инициатора заявки
    ///   - accept: `true` - одобрить заявку, `false` - отклонить
    func respondToFriendRequest(from userId: Int, accept: Bool) async throws

    /// Совершает действие со статусом друга/пользователя
    /// - Parameters:
    ///   - userId: `id` пользователя, к которому применяется действие
    ///   - option: вид действия - отправить заявку на добавление в друзья или удалить из списка друзей
    func friendAction(userId: Int, option: FriendAction) async throws

    /// Добавляет или убирает пользователя из черного списка
    ///
    /// В случае успеха обновляет черный список в `defaults`
    /// - Parameters:
    ///   - user: Пользователь, к которому применяется действие
    ///   - option: вид действия - добавить/убрать из черного списка
    func blacklistAction(user: UserResponse, option: BlacklistOption) async throws

    /// Ищет пользователей, чей логин содержит указанный текст
    /// - Parameter name: текст для поиска
    /// - Returns: Список пользователей, чей логин содержит указанный текст
    func findUsers(with name: String) async throws -> [UserResponse]

    /// Загружает черный список пользователей
    /// - Returns: Список пользователей в черном списке
    func getBlacklist() async throws -> [UserResponse]
}

extension SWClient: FriendsClient {
    public func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendsForUser(id: id)
        return try await makeResult(for: endpoint)
    }

    public func getFriendRequests() async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendRequests
        return try await makeResult(for: endpoint)
    }

    public func getBlacklist() async throws -> [UserResponse] {
        let endpoint = Endpoint.getBlacklist
        return try await makeResult(for: endpoint)
    }

    public func respondToFriendRequest(from userId: Int, accept: Bool) async throws {
        let endpoint: Endpoint = accept
            ? .acceptFriendRequest(from: userId)
            : .declineFriendRequest(from: userId)
        try await makeStatus(for: endpoint)
    }

    public func friendAction(userId: Int, option: FriendAction) async throws {
        let endpoint: Endpoint = option == .add
            ? .sendFriendRequest(to: userId)
            : .deleteFriend(userId)
        try await makeStatus(for: endpoint)
    }

    public func blacklistAction(user: UserResponse, option: BlacklistOption) async throws {
        let endpoint: Endpoint = option == .add
            ? .addToBlacklist(user.id)
            : .deleteFromBlacklist(user.id)
        try await makeStatus(for: endpoint)
    }

    public func findUsers(with name: String) async throws -> [UserResponse] {
        let endpoint = Endpoint.findUsers(with: name)
        return try await makeResult(for: endpoint)
    }
}

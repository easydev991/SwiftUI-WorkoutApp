import Foundation
import SWModels

/// Протокол для работы с сообщениями и диалогами
public protocol MessagesClient: Sendable {
    /// Запрашивает список диалогов для текущего пользователя
    /// - Returns: Список диалогов
    func getDialogs() async throws -> [DialogResponse]

    /// Запрашивает сообщения для выбранного диалога, по умолчанию лимит 30 сообщений
    /// - Parameter dialog: `id` диалога
    /// - Returns: Сообщения в диалоге
    func getMessages(for dialog: Int) async throws -> [MessageResponse]

    /// Отправляет сообщение указанному пользователю
    /// - Parameters:
    ///   - message: отправляемое сообщение
    ///   - userId: `id` получателя сообщения
    func sendMessage(_ message: String, to userId: Int) async throws

    /// Отмечает сообщения от выбранного пользователя как прочитанные
    /// - Parameter userId: `id` выбранного пользователя
    func markAsRead(from userId: Int) async throws

    /// Удаляет выбранный диалог
    /// - Parameter dialogId: `id` диалога для удаления
    func deleteDialog(_ dialogId: Int) async throws
}

extension SWClient: MessagesClient {
    public func getDialogs() async throws -> [DialogResponse] {
        let endpoint = Endpoint.getDialogs
        return try await makeResult(for: endpoint)
    }

    public func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        let endpoint = Endpoint.getMessages(dialogId: dialog)
        return try await makeResult(for: endpoint)
    }

    public func sendMessage(_ message: String, to userId: Int) async throws {
        let endpoint = Endpoint.sendMessageTo(message, userId)
        try await makeStatus(for: endpoint)
    }

    public func markAsRead(from userId: Int) async throws {
        let endpoint = Endpoint.markAsRead(from: userId)
        try await makeStatus(for: endpoint)
    }

    public func deleteDialog(_ dialogId: Int) async throws {
        let endpoint = Endpoint.deleteDialog(id: dialogId)
        try await makeStatus(for: endpoint)
    }
}

import Foundation
import SWModels
import SWNetwork

/// Протокол для работы с дневниками
public protocol JournalsClient: Sendable {
    /// Запрашивает список дневников для выбранного пользователя
    /// - Parameter userId: `id` выбранного пользователя
    /// - Returns: Список дневников
    func getJournals(for userId: Int) async throws -> [JournalResponse]

    /// Запрашивает дневник пользователя
    ///
    /// После обновления настроек дневника при помощи метода `editJournalSettings` нет смысла делать этот запрос,
    /// т.к. актуальные данные уже есть на экране
    /// - Parameters:
    ///   - userId: `id` пользователя
    ///   - journalId: `id` выбранного дневника
    /// - Returns: Общая информация о дневнике
    @available(*, deprecated, message: "Запрос не используется")
    func getJournal(for userId: Int, journalId: Int) async throws -> JournalResponse

    /// Меняет настройки дневника
    /// - Parameters:
    ///   - journalId: `id` выбранного дневника
    ///   - title: название дневника
    ///   - mainUserId: `id` главного пользователя
    ///   - viewAccess: доступ на просмотр
    ///   - commentAccess: доступ на комментирование
    func editJournalSettings(
        with journalId: Int,
        title: String,
        for mainUserId: Int?,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws

    /// Создает новый дневник для пользователя
    /// - Parameters:
    ///   - title: название дневника
    ///   - mainUserId: `id` главного пользователя
    func createJournal(with title: String, for mainUserId: Int?) async throws

    /// Запрашивает записи из дневника пользователя
    /// - Parameters:
    ///   - userId: `id` пользователя
    ///   - journalId: `id` выбранного дневника
    /// - Returns: Все записи из выбранного дневника
    func getJournalEntries(for userId: Int, journalId: Int) async throws -> [JournalEntryResponse]

    /// Удаляет выбранный дневник
    /// - Parameters:
    ///   - journalId: `id` дневника для удаления
    ///   - mainUserId: `id` владельца дневника (главного пользователя)
    func deleteJournal(with journalId: Int, for mainUserId: Int?) async throws
}

extension SWClient: JournalsClient {
    public func getJournals(for userId: Int) async throws -> [JournalResponse] {
        let endpoint = Endpoint.getJournals(userId: userId)
        return try await makeResult(for: endpoint)
    }

    public func getJournal(for userId: Int, journalId: Int) async throws -> JournalResponse {
        let endpoint = Endpoint.getJournal(userId: userId, journalId: journalId)
        return try await makeResult(for: endpoint)
    }

    public func editJournalSettings(
        with journalId: Int,
        title: String,
        for mainUserId: Int?,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws {
        guard let mainUserId else {
            throw APIError.invalidUserId
        }
        let endpoint = Endpoint.editJournalSettings(
            userId: mainUserId,
            journalId: journalId,
            title: title,
            viewAccess: viewAccess.rawValue,
            commentAccess: commentAccess.rawValue
        )
        try await makeStatus(for: endpoint)
    }

    public func createJournal(with title: String, for mainUserId: Int?) async throws {
        guard let mainUserId else {
            throw APIError.invalidUserId
        }
        let endpoint = Endpoint.createJournal(userId: mainUserId, title: title)
        try await makeStatus(for: endpoint)
    }

    public func getJournalEntries(for userId: Int, journalId: Int) async throws -> [JournalEntryResponse] {
        let endpoint = Endpoint.getJournalEntries(userId: userId, journalId: journalId)
        return try await makeResult(for: endpoint)
    }

    public func deleteJournal(with journalId: Int, for mainUserId: Int?) async throws {
        guard let mainUserId else {
            throw APIError.invalidUserId
        }
        let endpoint = Endpoint.deleteJournal(userId: mainUserId, journalId: journalId)
        try await makeStatus(for: endpoint)
    }
}

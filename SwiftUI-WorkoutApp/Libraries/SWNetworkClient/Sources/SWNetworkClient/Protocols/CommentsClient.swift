import Foundation
import SWModels

/// Протокол для работы с комментариями и записями
public protocol CommentsClient: Sendable {
    /// Добавить комментарий для площадки
    /// - Parameters:
    ///   - option: тип комментария (к площадке или мероприятию)
    ///   - entryText: текст комментария
    func addNewEntry(to option: TextEntryOption, entryText: String) async throws

    /// Изменить свой комментарий для площадки
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryId: `id` записи
    ///   - newEntryText: текст измененной записи
    func editEntry(for option: TextEntryOption, entryId: Int, newEntryText: String) async throws

    /// Удалить запись
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryId: `id` записи
    func deleteEntry(from option: TextEntryOption, entryId: Int) async throws
}

extension SWClient: CommentsClient {
    public func addNewEntry(to option: TextEntryOption, entryText: String) async throws {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .addCommentToPark(parkId: id, comment: entryText)
        case let .event(id):
            .addCommentToEvent(eventId: id, comment: entryText)
        case let .journal(ownerId, journalId):
            .saveJournalEntry(userId: ownerId, journalId: journalId, message: entryText)
        }
        try await makeStatus(for: endpoint)
    }

    public func editEntry(for option: TextEntryOption, entryId: Int, newEntryText: String) async throws {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .editParkComment(
                parkId: id,
                commentId: entryId,
                newComment: newEntryText
            )
        case let .event(id):
            .editEventComment(
                eventId: id,
                commentId: entryId,
                newComment: newEntryText
            )
        case let .journal(ownerId, journalId):
            .editEntry(
                userId: ownerId,
                journalId: journalId,
                entryId: entryId,
                newEntryText: newEntryText
            )
        }
        try await makeStatus(for: endpoint)
    }

    public func deleteEntry(from option: TextEntryOption, entryId: Int) async throws {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .deleteParkComment(id, commentId: entryId)
        case let .event(id):
            .deleteEventComment(id, commentId: entryId)
        case let .journal(ownerId, journalId):
            .deleteEntry(userId: ownerId, journalId: journalId, entryId: entryId)
        }
        try await makeStatus(for: endpoint)
    }
}

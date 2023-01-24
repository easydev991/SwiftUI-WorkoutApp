import DateFormatterService
import Foundation

/// Модель с информацией о записи в дневнике
struct JournalEntryResponse: Codable, Identifiable {
    let id: Int
    let journalID, authorID: Int?
    let authorName, message, createDate, modifyDate, authorImage: String?

    enum CodingKeys: String, CodingKey {
        case id, message
        case authorName = "name"
        case journalID = "journal_id"
        case authorID = "user_id"
        case authorImage = "image"
        case createDate = "create_date"
        case modifyDate = "modify_date"
    }
}

extension JournalEntryResponse {
    var imageURL: URL? {
        .init(string: authorImage.valueOrEmpty)
    }

    var formattedMessage: String {
        message.valueOrEmpty
            .withoutHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: createDate)
    }
}

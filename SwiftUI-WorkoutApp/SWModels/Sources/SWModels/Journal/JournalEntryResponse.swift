import DateFormatterService
import Foundation

/// Модель с информацией о записи в дневнике
public struct JournalEntryResponse: Codable, Identifiable {
    public let id: Int
    public let journalID, authorID: Int?
    public let authorName, message, createDate, modifyDate, authorImage: String?

    public enum CodingKeys: String, CodingKey {
        case id, message
        case authorName = "name"
        case journalID = "journal_id"
        case authorID = "user_id"
        case authorImage = "image"
        case createDate = "create_date"
        case modifyDate = "modify_date"
    }

    public init(
        id: Int,
        journalID: Int? = nil,
        authorID: Int? = nil,
        authorName: String? = nil,
        message: String? = nil,
        createDate: String? = nil,
        modifyDate: String? = nil,
        authorImage: String? = nil
    ) {
        self.id = id
        self.journalID = journalID
        self.authorID = authorID
        self.authorName = authorName
        self.message = message
        self.createDate = createDate
        self.modifyDate = modifyDate
        self.authorImage = authorImage
    }
}

public extension JournalEntryResponse {
    var imageURL: URL? {
        .init(string: authorImage.valueOrEmpty)
    }

    var formattedMessage: String {
        message.valueOrEmpty.withoutHTML
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: createDate)
    }
}

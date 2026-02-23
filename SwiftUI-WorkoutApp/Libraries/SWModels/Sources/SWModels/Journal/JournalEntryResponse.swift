import Foundation
import SWUtils

/// Модель с информацией о записи в дневнике
public struct JournalEntryResponse: Equatable, Codable, Identifiable, Sendable {
    public let id: Int
    public let journalId, authorId: Int?
    public let authorName, message, createDate, modifyDate, authorImage: String?

    public enum CodingKeys: String, CodingKey {
        case id, message
        case authorName = "name"
        case journalId = "journal_id"
        case authorId = "user_id"
        case authorImage = "image"
        case createDate = "create_date"
        case modifyDate = "modify_date"
    }

    public init(
        id: Int,
        journalId: Int? = nil,
        authorId: Int? = nil,
        authorName: String? = nil,
        message: String? = nil,
        createDate: String? = nil,
        modifyDate: String? = nil,
        authorImage: String? = nil
    ) {
        self.id = id
        self.journalId = journalId
        self.authorId = authorId
        self.authorName = authorName
        self.message = message
        self.createDate = createDate
        self.modifyDate = modifyDate
        self.authorImage = authorImage
    }
}

public extension JournalEntryResponse {
    var imageURL: URL? {
        authorImage.queryAllowedURL
    }

    var formattedMessage: String {
        guard let message, message.trueCount > 0 else {
            return ""
        }
        return message.withoutHtml()
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: createDate)
    }
}

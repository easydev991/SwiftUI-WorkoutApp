import Foundation

/// Модель с информацией о дневнике
struct JournalResponse: Codable, Identifiable, Equatable {
    let id: Int
    var titleOptional, lastMessageImage, createDate, modifyDate, lastMessageDate, lastMessageText, ownerName: String?
    let itemsCount, ownerID: Int?
    var viewAccess, commentAccess: Int?

    enum CodingKeys: String, CodingKey {
        case id = "journal_id"
        case titleOptional = "title"
        case itemsCount = "count"
        case lastMessageImage = "last_message_image"
        case createDate = "create_date"
        case modifyDate = "modify_date"
        case ownerID = "user_id"
        case ownerName = "name"
        case viewAccess = "view_access"
        case lastMessageDate = "last_message_date"
        case lastMessageText = "last_message_text"
        case commentAccess = "comment_access"
    }
}

extension JournalResponse {
    var imageURL: URL? {
        .init(string: lastMessageImage.valueOrEmpty)
    }
    var title: String {
        get { titleOptional.valueOrEmpty }
        set { titleOptional = newValue }
    }
    var formattedLastMessage: String {
        lastMessageText.valueOrEmpty
            .withoutHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var lastMessageDateString: String {
        FormatterService.readableDate(from: lastMessageDate)
    }
    var viewAccessType: JournalAccess {
        get { .init(viewAccess.valueOrZero) }
        set { viewAccess = newValue.rawValue }
    }
    var commentAccessType: JournalAccess {
        get { .init(commentAccess.valueOrZero) }
        set { commentAccess = newValue.rawValue }
    }
}

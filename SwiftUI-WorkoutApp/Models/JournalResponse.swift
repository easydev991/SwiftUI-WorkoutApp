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
    var viewAccessType: Constants.JournalAccess {
        get { .init(viewAccess.valueOrZero) }
        set { viewAccess = newValue.rawValue }
    }
    var commentAccessType: Constants.JournalAccess {
        get { .init(commentAccess.valueOrZero) }
        set { commentAccess = newValue.rawValue }
    }
    static var mock: JournalResponse {
        .init(
            id: 21758,
            titleOptional: "Test title",
            lastMessageImage: "avatar_default",
            createDate: "2022-05-21T10:48:17+03:00",
            modifyDate: "2022-05-22T09:48:17+03:00",
            lastMessageDate: "2022-05-22T09:48:29+03:00",
            lastMessageText: "Test last message",
            ownerName: "ninenineone",
            itemsCount: 2,
            ownerID: 10367,
            viewAccess: 2,
            commentAccess: 2
        )
    }
}

import DateFormatterService
import Foundation

/// Модель с информацией о дневнике
public struct JournalResponse: Codable, Identifiable, Equatable {
    public let id: Int
    public var titleOptional, lastMessageImage, createDate, modifyDate, lastMessageDate, lastMessageText, ownerName: String?
    public let itemsCount, ownerID: Int?
    public var viewAccess, commentAccess: Int?

    public enum CodingKeys: String, CodingKey {
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

    public init(
        id: Int,
        titleOptional: String? = nil,
        lastMessageImage: String? = nil,
        createDate: String? = nil,
        modifyDate: String? = nil,
        lastMessageDate: String? = nil,
        lastMessageText: String? = nil,
        ownerName: String? = nil,
        itemsCount: Int? = nil,
        ownerID: Int? = nil,
        viewAccess: Int? = nil,
        commentAccess: Int? = nil
    ) {
        self.id = id
        self.titleOptional = titleOptional
        self.lastMessageImage = lastMessageImage
        self.createDate = createDate
        self.modifyDate = modifyDate
        self.lastMessageDate = lastMessageDate
        self.lastMessageText = lastMessageText
        self.ownerName = ownerName
        self.itemsCount = itemsCount
        self.ownerID = ownerID
        self.viewAccess = viewAccess
        self.commentAccess = commentAccess
    }
}

public extension JournalResponse {
    var imageURL: URL? {
        lastMessageImage.queryAllowedURL
    }

    var title: String {
        get { titleOptional.valueOrEmpty }
        set { titleOptional = newValue }
    }

    var formattedLastMessage: String {
        lastMessageText.valueOrEmpty.withoutHTML
    }

    var lastMessageDateString: String {
        DateFormatterService.readableDate(from: lastMessageDate)
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

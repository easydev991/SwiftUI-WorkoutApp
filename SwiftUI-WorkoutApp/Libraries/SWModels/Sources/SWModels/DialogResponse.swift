import Foundation
import SWUtils

/// Модель с информацией о диалоге
public struct DialogResponse: Codable, Identifiable, Sendable {
    public let id: Int
    public let anotherUserImageStringURL: String?
    public let anotherUserName: String?
    public let lastMessageText: String?
    public let lastMessageDate: String?
    public let anotherUserID: Int?
    public var unreadCountOptional: Int?

    public enum CodingKeys: String, CodingKey {
        case id = "dialog_id"
        case anotherUserID = "user_id"
        case lastMessageText = "last_message_text"
        case lastMessageDate = "last_message_date"
        case anotherUserName = "name"
        case unreadCountOptional = "count"
        case anotherUserImageStringURL = "image"
    }

    public init(
        id: Int,
        anotherUserImageStringURL: String? = nil,
        anotherUserName: String? = nil,
        lastMessageText: String? = nil,
        lastMessageDate: String? = nil,
        anotherUserID: Int? = nil,
        unreadCountOptional: Int? = nil
    ) {
        self.id = id
        self.anotherUserImageStringURL = anotherUserImageStringURL
        self.anotherUserName = anotherUserName
        self.lastMessageText = lastMessageText
        self.lastMessageDate = lastMessageDate
        self.anotherUserID = anotherUserID
        self.unreadCountOptional = unreadCountOptional
    }
}

public extension DialogResponse {
    var anotherUserImageURL: URL? {
        anotherUserImageStringURL.queryAllowedURL
    }

    var lastMessageFormatted: String {
        (lastMessageText ?? "").withoutHTML
    }

    var lastMessageDateString: String {
        DateFormatterService.readableDate(
            from: lastMessageDate,
            showTimeInThisYear: false
        )
    }

    var hasUnreadMessages: Bool {
        unreadMessagesCount > 0
    }

    var unreadMessagesCount: Int {
        get { unreadCountOptional ?? 0 }
        set { unreadCountOptional = newValue }
    }
}

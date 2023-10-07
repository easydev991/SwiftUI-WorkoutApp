import DateFormatterService
import Foundation

/// Модель с информацией о диалоге
public struct DialogResponse: Codable, Identifiable {
    public let id: Int
    public let anotherUserImageStringURL: String?
    public let anotherUserName: String?
    public let lastMessageText: String?
    public let lastMessageDate: String?
    public let anotherUserID: Int?
    public var unreadCountOptional: Int?
    public let createdDate: String?

    public enum CodingKeys: String, CodingKey {
        case id = "dialog_id"
        case anotherUserID = "user_id"
        case lastMessageText = "last_message_text"
        case lastMessageDate = "last_message_date"
        case anotherUserName = "name"
        case unreadCountOptional = "count"
        case anotherUserImageStringURL = "image"
        case createdDate = "created"
    }

    public init(
        id: Int,
        anotherUserImageStringURL: String? = nil,
        anotherUserName: String? = nil,
        lastMessageText: String? = nil,
        lastMessageDate: String? = nil,
        anotherUserID: Int? = nil,
        unreadCountOptional: Int? = nil,
        createdDate: String? = nil
    ) {
        self.id = id
        self.anotherUserImageStringURL = anotherUserImageStringURL
        self.anotherUserName = anotherUserName
        self.lastMessageText = lastMessageText
        self.lastMessageDate = lastMessageDate
        self.anotherUserID = anotherUserID
        self.unreadCountOptional = unreadCountOptional
        self.createdDate = createdDate
    }
}

public extension DialogResponse {
    var anotherUserImageURL: URL? {
        .init(string: anotherUserImageStringURL.valueOrEmpty)
    }

    var lastMessageFormatted: String {
        lastMessageText.valueOrEmpty.withoutHTML
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
        get { unreadCountOptional.valueOrZero }
        set { unreadCountOptional = newValue }
    }

    static var emptyValue: DialogResponse {
        .init(
            id: .zero,
            anotherUserImageStringURL: nil,
            anotherUserName: nil,
            lastMessageText: nil,
            lastMessageDate: nil,
            anotherUserID: nil,
            createdDate: nil
        )
    }
}

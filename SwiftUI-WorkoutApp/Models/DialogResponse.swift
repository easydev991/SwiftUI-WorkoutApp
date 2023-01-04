import Foundation

/// Модель с информацией о диалоге
struct DialogResponse: Codable, Identifiable {
    let id: Int
    let anotherUserImageStringURL: String?
    let anotherUserName: String?
    let lastMessageText: String?
    let lastMessageDate: String?
    let anotherUserID: Int?
    var unreadCountOptional: Int?
    let createdDate: String?

    enum CodingKeys: String, CodingKey {
        case id = "dialog_id"
        case anotherUserID = "user_id"
        case lastMessageText = "last_message_text"
        case lastMessageDate = "last_message_date"
        case anotherUserName = "name"
        case unreadCountOptional = "count"
        case anotherUserImageStringURL = "image"
        case createdDate = "created"
    }
}

extension DialogResponse {
    var anotherUserImageURL: URL? {
        .init(string: anotherUserImageStringURL.valueOrEmpty)
    }
    var lastMessageFormatted: String {
        lastMessageText.valueOrEmpty
            .withoutHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var lastMessageDateString: String {
        FormatterService.readableDate(from: lastMessageDate)
    }
    var unreadMessagesCount: Int {
        get { unreadCountOptional.valueOrZero }
        set { unreadCountOptional = newValue }
    }
    static var emptyValue: DialogResponse {
        .init(id: .zero, anotherUserImageStringURL: nil, anotherUserName: nil, lastMessageText: nil, lastMessageDate: nil, anotherUserID: nil, createdDate: nil)
    }
}

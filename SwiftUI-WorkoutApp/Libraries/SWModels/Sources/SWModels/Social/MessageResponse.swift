import Foundation
import SWUtils

/// Модель сообщения в диалоге
public struct MessageResponse: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let userId: Int?
    public let message, name, created: String?

    public enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case id, message, name, created
    }
}

public extension MessageResponse {
    var formattedMessage: String {
        message.withoutHtmlOrEmpty()
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: created)
    }
}

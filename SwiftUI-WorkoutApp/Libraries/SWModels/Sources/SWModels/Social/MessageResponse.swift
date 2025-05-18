import Foundation
import SWUtils

/// Модель сообщения в диалоге
public struct MessageResponse: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let userID: Int?
    public let message, name, created: String?

    public enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case id, message, name, created
    }
}

public extension MessageResponse {
    var formattedMessage: String {
        (message ?? "").withoutHTML
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: created)
    }
}

import Foundation
import Utils

/// Модель сообщения в диалоге
public struct MessageResponse: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let userID: Int?
    public let message, name, created, imageStringURL: String?

    public enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case imageStringURL = "image"
        case id, message, name, created
    }
}

public extension MessageResponse {
    var imageURL: URL? {
        imageStringURL.queryAllowedURL
    }

    var formattedMessage: String {
        (message ?? "").withoutHTML
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: created)
    }
}

import DateFormatterService
import Foundation

/// Модель сообщения в диалоге
public struct MessageResponse: Codable, Identifiable, Hashable {
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
        .init(string: imageStringURL.valueOrEmpty)
    }

    var formattedMessage: String {
        message.valueOrEmpty
            .withoutHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var messageDateString: String {
        DateFormatterService.readableDate(from: created)
    }
}

import Foundation
import DateFormatterService

/// Модель сообщения в диалоге
struct MessageResponse: Codable, Identifiable, Hashable {
    let id: Int
    let userID: Int?
    let message, name, created, imageStringURL: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case imageStringURL = "image"
        case id, message, name, created
    }
}

extension MessageResponse {
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

//
//  MessageResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import Foundation

struct MessageResponse: Codable, Identifiable, Hashable {
    let id: Int
    let message: String?
    let userID: Int?
    let name: String?
    let created: String?
    let imageStringURL: String?

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
        FormatterService.readableDate(from: created)
    }
}

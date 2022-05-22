//
//  JournalEntryResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import Foundation

struct JournalEntryResponse: Codable, Identifiable {
    let id: Int
    let journalID, authorID: Int?
    let authorName, message, createDate, modifyDate, authorImage: String?

    enum CodingKeys: String, CodingKey {
        case id, message
        case authorName = "name"
        case journalID = "journal_id"
        case authorID = "user_id"
        case authorImage = "image"
        case createDate = "create_date"
        case modifyDate = "modify_date"
    }
}

extension JournalEntryResponse {
    var imageURL: URL? {
        .init(string: authorImage.valueOrEmpty)
    }
    var formattedMessage: String {
        message.valueOrEmpty
            .withoutHTML
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var messageDateString: String {
        FormatterService.readableDate(from: createDate)
    }
}

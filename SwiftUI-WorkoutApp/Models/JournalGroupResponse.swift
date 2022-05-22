//
//  JournalGroupResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.05.2022.
//

import Foundation

struct JournalGroupResponse: Codable, Identifiable {
    let id: Int
    let title, lastMessageImage, createDate, modifyDate, lastMessageDate, lastMessageText, ownerName: String?
    let itemsCount, ownerID: Int?
    var viewAccess, commentAccess: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case id = "journal_id"
        case itemsCount = "count"
        case lastMessageImage = "last_message_image"
        case createDate = "create_date"
        case modifyDate = "modify_date"
        case ownerID = "user_id"
        case ownerName = "name"
        case viewAccess = "view_access"
        case lastMessageDate = "last_message_date"
        case lastMessageText = "last_message_text"
        case commentAccess = "comment_access"
    }
}

extension JournalGroupResponse {
    var imageURL: URL? {
        .init(string: lastMessageImage.valueOrEmpty)
    }
    var lastMessageDateString: String {
        FormatterService.readableDate(from: lastMessageDate)
    }
    var viewAccessType: Constants.JournalAccess {
        get { .init(viewAccess.valueOrZero) }
        set { viewAccess = newValue.rawValue }
    }
    var commentAccessType: Constants.JournalAccess {
        get { .init(commentAccess.valueOrZero) }
        set { commentAccess = newValue.rawValue }
    }
    static var mock: JournalGroupResponse {
        .init(
            id: 21758,
            title: "Test title",
            lastMessageImage: nil,
            createDate: "2022-05-21T10:48:17+03:00",
            modifyDate: "2022-05-22T09:48:17+03:00",
            lastMessageDate: "2022-05-22T09:48:29+03:00",
            lastMessageText: "Test last message",
            ownerName: "ninenineone",
            itemsCount: 2,
            ownerID: 10367,
            viewAccess: 2,
            commentAccess: 2
        )
    }
}

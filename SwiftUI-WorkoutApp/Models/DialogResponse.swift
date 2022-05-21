//
//  DialogResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 21.05.2022.
//

import Foundation

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
    static var mock: DialogResponse {
        .init(
            id: 88777,
            anotherUserImageStringURL: "https://workout.su/uploads/avatars/2019/03/2019-03-21-23-03-49-rjk.jpg",
            anotherUserName: "WasD",
            lastMessageText: "Ошибка 500 это про пустые ответы? Я написал серверным.",
            lastMessageDate: "2022-05-14T17:35:45+00:00",
            anotherUserID: 30,
            unreadCountOptional: 5,
            createdDate: "2022-04-25T18:47:46+00:00"
        )
    }
}

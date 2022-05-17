//
//  Event.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.05.2022.
//

import Foundation

struct EventResponse: Codable, Identifiable {
    let id: Int
    /// Название события
    let title: String?
    let eventDescription, fullAddress, createDate, modifyDate, beginDate: String?
    let countryID, cityID, commentsCount: Int?
    let comments: [Comment]?
    let previewImageStringURL: String?
    let sportsGroundID: Int?
    let latitude, longitude: String?
    /// Количество участников
    let participantsCount: Int?
    let participants: [UserResponse]?
    /// `true` - предстоящее, `false` - прошедшее событие
    let isCurrent: Bool?
    /// `true` - пользователь является организатором, `false` - не является
    let isOrganizer: Bool?
    let photos: [Photo]?
    /// Логин автора события
    let name: String?
    let author: UserResponse?
    let canEdit, iAmGoing: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, photos, comments, author, name
        case fullAddress = "address"
        case previewImageStringURL = "preview"
        case eventDescription = "description"
        case createDate = "create_date"
        case modifyDate = "modify_date"
        case beginDate = "begin_date"
        case countryID = "country_id"
        case cityID = "city_id"
        case commentsCount = "comment_count"
        case sportsGroundID = "area_id"
        case participantsCount = "user_count"
        case isCurrent = "is_current"
        case participants = "training_users"
        case isOrganizer = "is_organizer"
        case canEdit = "can_edit"
        case iAmGoing = "train_here"
    }
}

extension EventResponse {
    var formattedTitle: String {
        title.valueOrEmpty
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalizingFirstLetter
    }

    var shortAddress: String {
        if let countryID = countryID, let cityID = cityID {
            return ShortAddressService().addressFor(countryID, cityID)
        } else {
            return "Не указан"
        }
    }

    var previewImageURL: URL? {
        .init(string: previewImageStringURL.valueOrEmpty)
    }
    var eventDateString: String {
        FormatterService.readableDate(from: beginDate)
    }

    static var emptyValue: EventResponse {
        .init(id: .zero, title: nil, eventDescription: nil, fullAddress: nil, createDate: nil, modifyDate: nil, beginDate: nil, countryID: nil, cityID: nil, commentsCount: nil, comments: nil, previewImageStringURL: nil, sportsGroundID: nil, latitude: nil, longitude: nil, participantsCount: nil, participants: nil, isCurrent: nil, isOrganizer: nil, photos: nil, name: nil, author: nil, canEdit: nil, iAmGoing: nil)
    }

    static var mock: EventResponse {
        Bundle.main.decodeJson(
            [EventResponse].self,
            fileName: "oldEvents.json"
        ).first!
    }
}

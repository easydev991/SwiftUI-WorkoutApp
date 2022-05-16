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
    let welcomeDescription: String?
    let createDate, modifyDate, beginDate: String?
    let countryID, cityID, commentsCount: Int?
    let previewImageStringURL: String?
    let sportsGroundID: Int?
    let latitude, longitude: String?
    /// Количество участников
    let participantsCount: Int?
    /// `true` - предстоящее, `false` - прошедшее событие
    let isCurrent: Bool?
    let photos: [Photo]?
    let author: UserResponse?
    /// Логин автора события
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id, title, latitude, longitude, photos, author, name
        case previewImageStringURL = "preview"
        case welcomeDescription = "description"
        case createDate = "create_date"
        case modifyDate = "modify_date"
        case beginDate = "begin_date"
        case countryID = "country_id"
        case cityID = "city_id"
        case commentsCount = "comment_count"
        case sportsGroundID = "area_id"
        case participantsCount = "user_count"
        case isCurrent = "is_current"
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

    static var mock: EventResponse {
        Bundle.main.decodeJson(
            [EventResponse].self,
            fileName: "oldEvents.json"
        ).first!
    }
}

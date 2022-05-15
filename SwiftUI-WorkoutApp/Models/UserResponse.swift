//
//  UserResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

/// Модель данных пользователя со всеми доступными свойствами
struct UserResponse: Codable, Hashable {
    let userName, fullName, email, imageStringURL: String?
    let birthDateIsoString: String? // "1990-11-25"
    let createdIsoDateTimeSec: String? // "2013-01-16T03:35:54+04:00"
    let userID, cityID, countryID, genderCode, friendsCount, journalsCount: Int?
    let friendRequestsCountString, sportsGroundsCountString: String? // "0"
    let addedSportsGrounds: [SportsGround]?
    /// Не используется
    let purchaseCustomerEditor: Bool?
    /// Не используется
    let lang: String? // "ru"
    /// Рейтинг на сайте, не используется
    let rating: Int? // 1

    enum CodingKeys: String, CodingKey {
        case userID = "id"
        case userName = "name"
        case imageStringURL = "image"
        case cityID = "city_id"
        case countryID = "country_id"
        case genderCode = "gender"
        case birthDateIsoString = "birth_date"
        case createdIsoDateTimeSec = "create_date"
        case fullName = "fullname"
        case friendsCount = "friend_count"
        case friendRequestsCountString = "friend_request_count"
        case sportsGroundsCountString = "area_count"
        case journalsCount = "journal_count"
        case purchaseCustomerEditor = "purchase_customer_editor"
        case addedSportsGrounds = "added_areas"
        case rating, email, lang
    }
}

extension UserResponse {
    var age: Int {
        let components = Calendar.current.dateComponents([.year], from: birthDate, to: .now)
        return components.year.valueOrZero
    }
    var birthDate: Date {
        FormatterService.dateFromShortIsoString(birthDateIsoString)
    }
    var avatarURL: URL? {
        .init(string: imageStringURL.valueOrEmpty)
    }
    var gender: String {
        Constants.Gender(genderCode.valueOrZero).description
    }
    var friendRequestsCount: Int {
        Int(friendRequestsCountString.valueOrEmpty).valueOrZero
    }
    var usedSportsGroundsCount: Int {
        Int(sportsGroundsCountString.valueOrEmpty).valueOrZero
    }
    var regForm: MainUserForm {
        .init(self)
    }
    static var emptyValue: UserResponse {
        .init(userName: nil, fullName: nil, email: nil, imageStringURL: nil, birthDateIsoString: nil, createdIsoDateTimeSec: nil, userID: nil, cityID: nil, countryID: nil, genderCode: nil, friendsCount: nil, journalsCount: nil, friendRequestsCountString: nil, sportsGroundsCountString: nil, addedSportsGrounds: nil, purchaseCustomerEditor: nil, lang: nil, rating: nil)
    }
}

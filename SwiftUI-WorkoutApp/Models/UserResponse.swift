//
//  UserResponse.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

struct UserResponse: Codable {
    let userName, fullName, email, imageStringURL: String?
    let birthDateIsoString: String? // "1990-11-25"
    let createdIsoDateTimeSec: String? // "2013-01-16T03:35:54+04:00"
    let userID, cityID, countryID, genderCode, friendsCount, journalsCount: Int?
    let friendRequestsCountString, sportsGroundsCountString: String? // "0"
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
        case rating, email, lang
    }
}

extension UserResponse {
    var age: Int {
        if let birthDate = birthDate {
            let components = Calendar.current.dateComponents([.year], from: birthDate, to: .now)
            return components.year.valueOrZero
        } else {
            return .zero
        }
    }
    var createdDate: Date? {
        if let createdIsoDateTimeSec = createdIsoDateTimeSec, !createdIsoDateTimeSec.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormat.isoDateTimeSec.rawValue
            return dateFormatter.date(from: createdIsoDateTimeSec)
        } else {
            return nil
        }
    }
    var birthDate: Date? {
        if let birthDateIsoString = birthDateIsoString, !birthDateIsoString.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = DateFormat.isoDate.rawValue
            return dateFormatter.date(from: birthDateIsoString)
        } else {
            return nil
        }
    }
    var gender: String {
        genderCode == .zero ? "Мужчина" : "Женщина"
    }
    var friendRequestsCount: Int {
        Int(friendRequestsCountString.valueOrEmpty).valueOrZero
    }
    var sportsGroundsCount: Int {
        Int(sportsGroundsCountString.valueOrEmpty).valueOrZero
    }
}

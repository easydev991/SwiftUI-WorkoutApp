import Foundation
import Utils

/// Модель данных пользователя со всеми доступными свойствами
struct UserResponse: Codable, Hashable {
    let userName, fullName, email, imageStringURL: String?
    let birthDateIsoString: String? // "1990-11-25"
    let createdIsoDateTimeSec: String? // "2013-01-16T03:35:54+04:00"
    let userID, cityID, countryID, genderCode, friendsCount, journalsCount: Int?
    let friendRequestsCountString, sportsGroundsCountString: String? // "0"
    let addedSportsGrounds: [SportsGround]?

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
        case addedSportsGrounds = "added_areas"
        case email
    }
}

extension UserResponse {
    var age: Int {
        let components = Calendar.current.dateComponents([.year], from: birthDate, to: .now)
        return components.year.valueOrZero
    }
    var birthDate: Date {
        FormatterService.dateFromString(
            birthDateIsoString,
            format: .isoShortDate
        )
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
    static var mock: UserResponse {
        .init(userName: "TestUserName", fullName: "TestFullName", email: "test@mail.ru", imageStringURL: "avatar_default", birthDateIsoString: "1990-11-25", createdIsoDateTimeSec: nil, userID: .zero, cityID: 1, countryID: 17, genderCode: 1, friendsCount: 5, journalsCount: 2, friendRequestsCountString: "3", sportsGroundsCountString: "4", addedSportsGrounds: nil)
    }
    static var emptyValue: UserResponse {
        .init(userName: nil, fullName: nil, email: nil, imageStringURL: nil, birthDateIsoString: nil, createdIsoDateTimeSec: nil, userID: nil, cityID: nil, countryID: nil, genderCode: nil, friendsCount: nil, journalsCount: nil, friendRequestsCountString: nil, sportsGroundsCountString: nil, addedSportsGrounds: nil)
    }
}

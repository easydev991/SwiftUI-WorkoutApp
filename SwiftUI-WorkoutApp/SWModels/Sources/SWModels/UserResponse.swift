import DateFormatterService
import Foundation

/// Модель данных пользователя со всеми доступными свойствами
public struct UserResponse: Codable, Hashable {
    public let userName, fullName, email, imageStringURL: String?
    public let birthDateIsoString: String? // "1990-11-25"
    public let createdIsoDateTimeSec: String? // "2013-01-16T03:35:54+04:00"
    public let userID, cityID, countryID, genderCode, friendsCount, journalsCount: Int?
    public let friendRequestsCountString, sportsGroundsCountString: String? // "0"
    public let addedSportsGrounds: [SportsGround]?

    public enum CodingKeys: String, CodingKey {
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

    public init(
        userName: String? = nil,
        fullName: String? = nil,
        email: String? = nil,
        imageStringURL: String? = nil,
        birthDateIsoString: String? = nil,
        createdIsoDateTimeSec: String? = nil,
        userID: Int? = nil,
        cityID: Int? = nil,
        countryID: Int? = nil,
        genderCode: Int? = nil,
        friendsCount: Int? = nil,
        journalsCount: Int? = nil,
        friendRequestsCountString: String? = nil,
        sportsGroundsCountString: String? = nil,
        addedSportsGrounds: [SportsGround]? = nil
    ) {
        self.userName = userName
        self.fullName = fullName
        self.email = email
        self.imageStringURL = imageStringURL
        self.birthDateIsoString = birthDateIsoString
        self.createdIsoDateTimeSec = createdIsoDateTimeSec
        self.userID = userID
        self.cityID = cityID
        self.countryID = countryID
        self.genderCode = genderCode
        self.friendsCount = friendsCount
        self.journalsCount = journalsCount
        self.friendRequestsCountString = friendRequestsCountString
        self.sportsGroundsCountString = sportsGroundsCountString
        self.addedSportsGrounds = addedSportsGrounds
    }
}

public extension UserResponse {
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: .now).year.valueOrZero
    }

    var birthDate: Date {
        DateFormatterService.dateFromString(birthDateIsoString, format: .isoShortDate)
    }

    var avatarURL: URL? {
        imageStringURL.queryAllowedURL
    }

    var gender: String {
        NSLocalizedString((Gender(genderCode.valueOrZero)?.description).valueOrEmpty, comment: "")
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
        .init(
            userName: nil,
            fullName: nil,
            email: nil,
            imageStringURL: nil,
            birthDateIsoString: nil,
            createdIsoDateTimeSec: nil,
            userID: nil,
            cityID: nil,
            countryID: nil,
            genderCode: nil,
            friendsCount: nil,
            journalsCount: nil,
            friendRequestsCountString: nil,
            sportsGroundsCountString: nil,
            addedSportsGrounds: nil
        )
    }
}

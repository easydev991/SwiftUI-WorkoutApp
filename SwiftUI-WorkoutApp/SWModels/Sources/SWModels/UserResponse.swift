import Foundation
import Utils

/// Модель данных пользователя со всеми доступными свойствами
public struct UserResponse: Codable, Identifiable, Hashable {
    public let id: Int
    public let userName, fullName, email, imageStringURL: String?
    public let cityID, countryID, genderCode, friendsCount, journalsCount: Int?
    public let addedSportsGrounds: [SportsGround]?
    /// Пример: "1990-11-25"
    let birthDateIsoString: String?
    /// Пример: "2013-01-16T03:35:54+04:00"
    let createdIsoDateTimeSec: String?
    let friendRequestsCountString, sportsGroundsCountString: String? // "0"

    public enum CodingKeys: String, CodingKey {
        case id
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
        id: Int,
        userName: String? = nil,
        fullName: String? = nil,
        email: String? = nil,
        imageStringURL: String? = nil,
        birthDateIsoString: String? = nil,
        createdIsoDateTimeSec: String? = nil,
        cityID: Int? = nil,
        countryID: Int? = nil,
        genderCode: Int? = nil,
        friendsCount: Int? = nil,
        journalsCount: Int? = nil,
        friendRequestsCountString: String? = nil,
        sportsGroundsCountString: String? = nil,
        addedSportsGrounds: [SportsGround]? = nil
    ) {
        self.id = id
        self.userName = userName
        self.fullName = fullName
        self.email = email
        self.imageStringURL = imageStringURL
        self.birthDateIsoString = birthDateIsoString
        self.createdIsoDateTimeSec = createdIsoDateTimeSec
        self.cityID = cityID
        self.countryID = countryID
        self.genderCode = genderCode
        self.friendsCount = friendsCount
        self.journalsCount = journalsCount
        self.friendRequestsCountString = friendRequestsCountString
        self.sportsGroundsCountString = sportsGroundsCountString
        self.addedSportsGrounds = addedSportsGrounds
    }
    
    public init(dialog: DialogResponse) {
        self.init(
            id: dialog.id,
            userName: dialog.anotherUserName,
            imageStringURL: dialog.anotherUserImageURL?.absoluteString
        )
    }
}

public extension UserResponse {
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: .now).year ?? 0
    }

    var birthDate: Date {
        DateFormatterService.dateFromString(birthDateIsoString, format: .isoShortDate)
    }

    var avatarURL: URL? {
        imageStringURL.queryAllowedURL
    }
    
    var genderWithAge: String {
        let localizedAgeString = String.localizedStringWithFormat(
            NSLocalizedString("ageInYears", comment: ""),
            age
        )
        return genderString.isEmpty
        ? localizedAgeString
        : genderString + ", " + localizedAgeString
    }
    
    var friendsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("friendsCount", comment: ""),
            friendsCount ?? 0
        )
    }

    var usedSportsGroundsCount: Int {
        guard let sportsGroundsCountString else { return 0 }
        return Int(sportsGroundsCountString) ?? 0
    }
    
    var hasJournals: Bool { journalsCount ?? 0 > 0 }
    
    var journalsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("journalsCount", comment: ""),
            journalsCount ?? 0
        )
    }

    var hasFriends: Bool { friendsCount ?? 0 > 0 }

    var hasAddedGrounds: Bool {
        guard let addedSportsGrounds, !addedSportsGrounds.isEmpty else {
            return false
        }
        return true
    }
    
    var addedSportsGroundsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("groundsCount", comment: ""),
            addedSportsGrounds?.count ?? 0
        )
    }

    /// Тренируется на каких-нибудь площадках
    var hasUsedGrounds: Bool { usedSportsGroundsCount > 0 }
    
    var usesSportsGroundsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("groundsCount", comment: ""),
            usedSportsGroundsCount
        )
    }
    
    /// Заголовок для экрана отправки сообщения
    var messageFor: String {
        if let userName {
            "Сообщение для \(userName)"
        } else {
            "Сообщение"
        }
    }

    /// Достаточно ли данных для отображения профиля пользователя
    ///
    /// Если данных недостаточно, загружаем данные с сервера
    var isFull: Bool {
        id != 0
        && avatarURL != nil
        && userName != ""
        && age != 0
        && countryID != 0
    }
    
    static var emptyValue: UserResponse {
        .init(
            id: 0,
            userName: nil,
            fullName: nil,
            email: nil,
            imageStringURL: nil,
            birthDateIsoString: nil,
            createdIsoDateTimeSec: nil,
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

private extension UserResponse {
    var genderString: String {
        guard let genderCode, let gender = Gender(genderCode) else { return "" }
        return NSLocalizedString(gender.description, comment: "")
    }
}

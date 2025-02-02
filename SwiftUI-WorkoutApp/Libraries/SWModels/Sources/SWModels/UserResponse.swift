import Foundation
import SWUtils

/// Модель данных пользователя со всеми доступными свойствами
public struct UserResponse: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let userName, fullName, email, imageStringURL: String?
    public let cityID, countryID, genderCode, friendsCount, journalsCount: Int?
    public let addedParks: [Park]?
    /// Пример: "1990-11-25"
    let birthDateIsoString: String?
    let parksCountString: String? // "0"

    public enum CodingKeys: String, CodingKey {
        case id
        case userName = "name"
        case imageStringURL = "image"
        case cityID = "city_id"
        case countryID = "country_id"
        case genderCode = "gender"
        case birthDateIsoString = "birth_date"
        case fullName = "fullname"
        case friendsCount = "friend_count"
        case parksCountString = "area_count"
        case journalsCount = "journal_count"
        case addedParks = "added_areas"
        case email
    }

    public init(
        id: Int,
        userName: String? = nil,
        fullName: String? = nil,
        email: String? = nil,
        imageStringURL: String? = nil,
        birthDateIsoString: String? = nil,
        cityID: Int? = nil,
        countryID: Int? = nil,
        genderCode: Int? = nil,
        friendsCount: Int? = nil,
        journalsCount: Int? = nil,
        parksCountString: String? = nil,
        addedParks: [Park]? = nil
    ) {
        self.id = id
        self.userName = userName
        self.fullName = fullName
        self.email = email
        self.imageStringURL = imageStringURL
        self.birthDateIsoString = birthDateIsoString
        self.cityID = cityID
        self.countryID = countryID
        self.genderCode = genderCode
        self.friendsCount = friendsCount
        self.journalsCount = journalsCount
        self.parksCountString = parksCountString
        self.addedParks = addedParks
    }

    public init(dialog: DialogResponse) {
        self.init(
            id: dialog.anotherUserID ?? 0,
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

    var usedParksCount: Int {
        guard let parksCountString else { return 0 }
        return Int(parksCountString) ?? 0
    }

    var hasJournals: Bool { journalsCount ?? 0 > 0 }

    var journalsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("journalsCount", comment: ""),
            journalsCount ?? 0
        )
    }

    var hasFriends: Bool { friendsCount ?? 0 > 0 }

    var hasAddedParks: Bool {
        guard let addedParks, !addedParks.isEmpty else {
            return false
        }
        return true
    }

    var addedParksCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("parksCount", comment: ""),
            addedParks?.count ?? 0
        )
    }

    /// Тренируется на каких-нибудь площадках
    var hasUsedParks: Bool { usedParksCount > 0 }

    var usesParksCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("parksCount", comment: ""),
            usedParksCount
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

    /// Добавил(-а) площадки
    var addedParksString: String {
        switch Gender(genderCode ?? 0) {
        case .male, .unspecified, .none:
            "Добавил площадки"
        case .female:
            "Добавила площадки"
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
            cityID: nil,
            countryID: nil,
            genderCode: nil,
            friendsCount: nil,
            journalsCount: nil,
            parksCountString: nil,
            addedParks: nil
        )
    }
}

private extension UserResponse {
    var genderString: String {
        guard let genderCode, let gender = Gender(genderCode) else { return "" }
        return NSLocalizedString(gender.description, comment: "")
    }
}

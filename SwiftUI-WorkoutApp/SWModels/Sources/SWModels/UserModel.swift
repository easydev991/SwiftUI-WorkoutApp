import Foundation
import Utils

/// Упрощенная модель данных пользователя
public struct UserModel: Identifiable, Hashable {
    public let id: Int
    public let imageURL: URL?
    public let name: String
    public let gender: String
    public let age: Int
    public let countryID: Int
    public let cityID: Int
    private let usesSportsGrounds: Int
    public let addedSportsGrounds: [SportsGround]
    private let friendsCount, journalsCount: Int

    public init(_ user: UserResponse?) {
        if let user {
            self.id = user.userID ?? 0
            self.imageURL = user.avatarURL
            self.name = user.userName ?? ""
            self.gender = "\(user.gender), "
            self.age = user.age
            self.countryID = user.countryID ?? 0
            self.cityID = user.cityID ?? 0
            self.usesSportsGrounds = user.usedSportsGroundsCount
            self.addedSportsGrounds = user.addedSportsGrounds ?? []
            self.friendsCount = user.friendsCount ?? 0
            self.journalsCount = user.journalsCount ?? 0
        } else {
            self = .emptyValue
        }
    }

    public init(from dialog: DialogResponse) {
        self.init(
            id: dialog.anotherUserID ?? 0,
            imageURL: dialog.anotherUserImageURL,
            name: dialog.anotherUserName ?? "",
            gender: "",
            age: 0,
            countryID: 0,
            cityID: 0,
            usesSportsGrounds: 0,
            addedSportsGrounds: [],
            friendsCount: 0,
            journalsCount: 0
        )
    }

    public init(
        id: Int,
        imageURL: URL?,
        name: String,
        gender: String,
        age: Int,
        countryID: Int,
        cityID: Int,
        usesSportsGrounds: Int,
        addedSportsGrounds: [SportsGround],
        friendsCount: Int,
        journalsCount: Int
    ) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.gender = gender
        self.age = age
        self.countryID = countryID
        self.cityID = cityID
        self.usesSportsGrounds = usesSportsGrounds
        self.addedSportsGrounds = addedSportsGrounds
        self.friendsCount = friendsCount
        self.journalsCount = journalsCount
    }
}

public extension UserModel {
    var genderWithAge: String {
        gender + String.localizedStringWithFormat(
            NSLocalizedString("ageInYears", comment: ""),
            age
        )
    }

    var friendsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("friendsCount", comment: ""),
            friendsCount
        )
    }

    var hasJournals: Bool { journalsCount > 0 }

    var hasFriends: Bool { friendsCount > 0 }

    var hasAddedGrounds: Bool { !addedSportsGrounds.isEmpty }

    /// Тренируется на каких-нибудь площадках
    var hasUsedGrounds: Bool { usesSportsGrounds > 0 }

    var journalsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("journalsCount", comment: ""),
            journalsCount
        )
    }

    var usesSportsGroundsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("groundsCount", comment: ""),
            usesSportsGrounds
        )
    }

    var addedSportsGroundsCountString: String {
        String.localizedStringWithFormat(
            NSLocalizedString("groundsCount", comment: ""),
            addedSportsGrounds.count
        )
    }

    var shortAddress: String {
        ShortAddressService(countryID, cityID).address
    }

    var isFull: Bool {
        id != .zero
            && imageURL != nil
            && name != ""
            && age != .zero
            && countryID != .zero
    }

    static var emptyValue: UserModel {
        .init(
            id: 0,
            imageURL: nil,
            name: "",
            gender: "",
            age: 0,
            countryID: 0,
            cityID: 0,
            usesSportsGrounds: 0,
            addedSportsGrounds: [],
            friendsCount: 0,
            journalsCount: 0
        )
    }
}

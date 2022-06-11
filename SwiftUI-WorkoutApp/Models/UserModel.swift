import Foundation
import Utils

/// Упрощенная модель данных пользователя
struct UserModel: Identifiable, Hashable {
    let id: Int
    let imageURL: URL?
    let name: String
    let gender: String
    let age: Int
    let countryID: Int
    let cityID: Int
    let usesSportsGrounds: Int
    let addedSportsGrounds: [SportsGround]
    let friendsCount, journalsCount: Int

    init(_ user: UserResponse?) {
        if let user = user {
            self.id = user.userID.valueOrZero
            self.imageURL = user.avatarURL
            self.name = user.userName.valueOrEmpty
            self.gender = "\(user.gender), "
            self.age = user.age
            self.countryID = user.countryID.valueOrZero
            self.cityID = user.cityID.valueOrZero
            self.usesSportsGrounds = user.usedSportsGroundsCount
            self.addedSportsGrounds = user.addedSportsGrounds ?? []
            self.friendsCount = user.friendsCount.valueOrZero
            self.journalsCount = user.journalsCount.valueOrZero
        } else {
            self = .emptyValue
        }
    }

    init(from dialog: DialogResponse) {
        self.init(
            id: dialog.anotherUserID.valueOrZero,
            imageURL: dialog.anotherUserImageURL,
            name: dialog.anotherUserName.valueOrEmpty,
            gender: "",
            age: .zero,
            countryID: .zero,
            cityID: .zero,
            usesSportsGrounds: .zero,
            addedSportsGrounds: [],
            friendsCount: .zero,
            journalsCount: .zero
        )
    }

    init(id: Int, imageURL: URL?, name: String, gender: String, age: Int, countryID: Int, cityID: Int, usesSportsGrounds: Int, addedSportsGrounds: [SportsGround], friendsCount: Int, journalsCount: Int) {
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

extension UserModel {
    var shortAddress: String {
        ShortAddressService().addressFor(countryID, cityID)
    }
    var isFull: Bool {
        id != .zero
        && imageURL != nil
        && name != ""
        && age != .zero
        && countryID != .zero
    }
    static var emptyValue: UserModel {
        .init(id: .zero, imageURL: nil, name: "", gender: "", age: .zero, countryID: .zero, cityID: .zero, usesSportsGrounds: .zero, addedSportsGrounds: [], friendsCount: .zero, journalsCount: .zero)
    }
}

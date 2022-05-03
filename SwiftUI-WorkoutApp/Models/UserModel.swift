//
//  UserModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 03.05.2022.
//

import Foundation

struct UserModel: Identifiable, Equatable {
    let id: Int
    let imageURL: URL?
    let name: String
    let gender: String
    let age: Int
    let countryID: Int
    let cityID: Int
    let usesSportsGrounds: Int
#warning("TODO: маппить из списка площадок")
    let addedSportsGrounds = Int.zero
    let friendsCount, journalsCount: Int

    init(_ user: UserResponse) {
        self.id = user.userID.valueOrZero
        self.imageURL = .init(string: user.imageStringURL.valueOrEmpty)
        self.name = user.userName.valueOrEmpty
        self.gender = user.gender
        self.age = user.age
        self.countryID = user.countryID.valueOrZero
        self.cityID = user.cityID.valueOrZero
        self.usesSportsGrounds = user.sportsGroundsCount
        self.friendsCount = user.friendsCount.valueOrZero
        self.journalsCount = user.journalsCount.valueOrZero
    }

    init(id: Int, imageURL: URL?, name: String, gender: String, age: Int, countryID: Int, cityID: Int, usesSportsGrounds: Int, friendsCount: Int, journalsCount: Int) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.gender = gender
        self.age = age
        self.countryID = countryID
        self.cityID = cityID
        self.usesSportsGrounds = usesSportsGrounds
        self.friendsCount = friendsCount
        self.journalsCount = journalsCount
    }

    static var emptyValue: UserModel {
        .init(id: .zero, imageURL: nil, name: "", gender: "", age: .zero, countryID: .zero, cityID: .zero, usesSportsGrounds: .zero, friendsCount: .zero, journalsCount: .zero)
    }
}

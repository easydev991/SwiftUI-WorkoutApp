//
//  PersonsListView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct TempPersonModel: Identifiable {
    let id: Int
    let imageStringURL: String
    let name, genderAge, shortAddress: String
    let usesSportsGrounds, addedSportsGrounds: Int
    let friendsCount, journalsCount: Int
    var isMainUser: Bool

    static let mockMain = TempPersonModel(
        id: 22,
        imageStringURL: "https://workout.su/uploads/avatars/47300ad3563cee8a505e7b68663dc3bd4564c44e.jpg",
        name: "Admin",
        genderAge: "Мужчина, 29 лет",
        shortAddress: "Россия, Москва",
        usesSportsGrounds: 1,
        addedSportsGrounds: 2,
        friendsCount: 3,
        journalsCount: 4,
        isMainUser: true
    )

    static let mockSingle = TempPersonModel(
        id: 22,
        imageStringURL: "https://workout.su/uploads/avatars/SL372308.JPG",
        name: "artemyh",
        genderAge: "Мужчина, 25 лет",
        shortAddress: "Россия, Москва",
        usesSportsGrounds: 1,
        addedSportsGrounds: 0,
        friendsCount: 1,
        journalsCount: 1,
        isMainUser: false
    )

    static let mockArray: [TempPersonModel] = [
        .init(
            id: 22377,
            imageStringURL: "https://workout.su/uploads/avatars/1442580670.jpg",
            name: "Albert_88",
            genderAge: "Мужчина, 30 лет",
            shortAddress: "Россия, Тимашевск1111",
            usesSportsGrounds: 1,
            addedSportsGrounds: 3,
            friendsCount: .zero,
            journalsCount: 1,
            isMainUser: false
        ),
        .init(
            id: 15186,
            imageStringURL: "https://workout.su/uploads/avatars/SL372308.JPG",
            name: "artemyh",
            genderAge: "Мужчина, 35 лет",
            shortAddress: "Россия, Первомайск",
            usesSportsGrounds: .zero,
            addedSportsGrounds: 1,
            friendsCount: 5,
            journalsCount: .zero,
            isMainUser: false
        ),
        .init(
            id: 3385,
            imageStringURL: "https://workout.su/uploads/avatars/47300ad3563cee8a505e7b68663dc3bd4564c44e.jpg",
            name: "Vladworkout2000",
            genderAge: "Мужчина, 20 лет",
            shortAddress: "Россия, Горловка",
            usesSportsGrounds: 6,
            addedSportsGrounds: .zero,
            friendsCount: .zero,
            journalsCount: 5,
            isMainUser: false
        )
    ]
}

struct PersonsListView: View {
    var body: some View {
#warning("TODO: интеграция с сервером")
        List(TempPersonModel.mockArray) { person in
            NavigationLink {
                PersonProfileView(viewModel: .init(userID: person.id))
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                PersonRow(model: person)
            }
        }
    }
}

struct PersonsListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonsListView()
    }
}

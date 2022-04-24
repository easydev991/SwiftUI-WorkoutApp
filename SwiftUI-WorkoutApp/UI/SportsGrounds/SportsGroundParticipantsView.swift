//
//  SportsGroundParticipantsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 24.04.2022.
//

import SwiftUI

struct TempPersonModel: Identifiable {
    let id: Int
    let imageStringURL, name, address: String

    static let mock: [TempPersonModel] = [
        .init(
            id: 22377,
            imageStringURL: "https://workout.su/uploads/avatars/1442580670.jpg",
            name: "Albert_88",
            address: "Россия, Тимашевск"
        ),
        .init(
            id: 15186,
            imageStringURL: "https://workout.su/uploads/avatars/SL372308.JPG",
            name: "artemyh",
            address: "Россия, Первомайск"
        ),
        .init(
            id: 3385,
            imageStringURL: "https://workout.su/uploads/avatars/47300ad3563cee8a505e7b68663dc3bd4564c44e.jpg",
            name: "Vladworkout2000",
            address: "Россия, Горловка"
        )
    ]
}

struct SportsGroundParticipantsView: View {
    let model: SportsGround
    var body: some View {
#warning("Запрашивать с бэка и отображать список реальных участников")
        List(TempPersonModel.mock) { person in
            NavigationLink {
                Text(person.name)
                    .navigationTitle("Профиль")
            } label: {
                personView(person)
            }
        }
        .navigationTitle("Здесь тренируются")
    }
}

private extension SportsGroundParticipantsView {
    func personView(_ model: TempPersonModel) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: .init(string: model.imageStringURL)) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .smallProfileImageRect()
                case .failure:
                    Image(systemName: "person.fill")
                default:
                    ProgressView()
                }
            }
            VStack(alignment: .leading) {
                Text(model.name)
                    .fontWeight(.medium)
                Text(model.address)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

struct SportsGroundParticipantsView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundParticipantsView(model: .mock)
    }
}

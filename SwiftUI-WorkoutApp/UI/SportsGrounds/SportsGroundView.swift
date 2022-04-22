//
//  SportsGroundView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 22.04.2022.
//

import SwiftUI

struct SportsGroundView: View {
    let model: SportsGround

    var body: some View {
        Form {
            Section {
                titleSection()
            }
            Section {
                Text("Горизонтальная коллекция фотографий")
            }
            Section {
                Text("Фото с предпросмотром карты")
            }
            Section {
                Text("Здесь тренируются ХХХ человек с переходом на экран участников")
            }
            Section {
                Text("Свичер 'Тренируюсь здесь'")
            }
            Section {
                Text("Кнопка для создания мероприятия")
            }
            Section("Добавил") {
                Text("Фото и ник автора")
            }
            Section("Комментарии") {
                Text("Список комментариев")
            }
            Section {
                Text("Кнопка для добавления комментария")
            }
        }
        .navigationTitle("Площадка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SportsGroundView {
    func titleSection() -> some View {
        HStack {
            Text(model.title)
                .font(.title2.bold())
            Spacer()
            Text(model.subtitle)
                .foregroundColor(.secondary)
        }
    }
}

struct SportsGroundView_Previews: PreviewProvider {
    static var previews: some View {
        SportsGroundView(model: .mock)
    }
}

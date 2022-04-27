//
//  EventsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

struct EventsView: View {
    var body: some View {
        NavigationView {
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать экран со списком мероприятий")
            dummyView()
                .navigationTitle("Мероприятия")
        }
    }
}

private extension EventsView {
    func dummyView() -> some View {
        VStack(spacing: 16) {
            Text("Нет запланированных мероприятий")
                .font(.title)
                .multilineTextAlignment(.center)
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
                .frame(width: 180)
            NavigationLink {
#warning("TODO: Сверстать экран для создания мероприятия")
                Text("Экран для создания мероприятия")
                    .navigationTitle("Мероприятие")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                Text("Создать мероприятие")
                    .roundedBorderedStyle()
            }
        }
        .padding()
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .previewDevice("iPhone 13 mini")
    }
}

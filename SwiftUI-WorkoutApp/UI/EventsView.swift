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
#warning("TODO: сверстать экран с мероприятиями")
            dummyView()
                .navigationTitle("Мероприятия")
        }
    }
}

private extension EventsView {
    func dummyView() -> some View {
        VStack {
            Text("Нет запланированных мероприятий")
                .font(.title.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
            Image(systemName: "calendar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary.opacity(0.5))
                .frame(width: 200)
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

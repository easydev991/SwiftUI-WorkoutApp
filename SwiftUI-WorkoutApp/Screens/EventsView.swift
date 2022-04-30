//
//  EventsView.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 16.04.2022.
//

import SwiftUI

enum EventType: String, CaseIterable {
    case future = "Планируемые"
    case past = "Прошедшие"
}

struct EventsView: View {
    @State private var selectedEventType = EventType.future

    var body: some View {
        NavigationView {
#warning("TODO: интеграция с сервером")
#warning("TODO: сверстать экран со списком мероприятий")
            VStack {
                segmentedControl()
                content()
            }
            .navigationTitle("Мероприятия")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension EventsView {
    func segmentedControl() -> some View {
        Picker("Тип мероприятия", selection: $selectedEventType) {
            ForEach(EventType.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }

    func content() -> AnyView {
        switch selectedEventType {
        case .future: return AnyView(dummyView())
        case .past: return AnyView(eventsList())
        }
    }

#warning("TODO: убрать временный хардкод после реализации фичи")
    func eventsList() -> some View {
        List(0..<15) { id in
            Text("Тренировка № \(id)")
        }
    }

    func dummyView() -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Нет запланированных мероприятий")
                .font(.title2)
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
            Spacer()
        }
        .padding()
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 13 mini")
    }
}

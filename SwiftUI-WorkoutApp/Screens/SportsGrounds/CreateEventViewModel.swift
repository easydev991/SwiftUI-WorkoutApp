//
//  CreateEventViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class CreateEventViewModel: ObservableObject {
    let ground: SportsGround
    @Published var eventName = ""
    @Published var eventDate = Date()
    @Published var eventDescription = ""
    @Published var isEventCreated = false

    var maxDate: Date {
        Calendar.current.date(
            byAdding: .year,
            value: Constants.maxEventFutureYear,
            to: .now
        ) ?? .now
    }
    var isCreateButtonActive: Bool {
        eventName.count >= 6
    }

    init(with model: SportsGround) {
        ground = model
    }

    func createEventAction() {
#warning("TODO: интеграция с сервером")
#warning("TODO: уведомлять о проблемах при отправке мероприятия")
        isEventCreated = true
    }
}

//
//  CreateEventViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 30.04.2022.
//

import Foundation

final class CreateEventViewModel: ObservableObject {
    let mode: Mode
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
        eventName.count >= Constants.minPasswordSize
    }

    init(mode: Mode) {
        self.mode = mode
    }

    func createEventAction() {
#warning("TODO: интеграция с сервером")
#warning("TODO: уведомлять о проблемах при отправке мероприятия")
        isEventCreated = true
    }

    func eventAlertClosed() {
        eventName = ""
        eventDate = .now
        eventDescription = ""
        isEventCreated = false
    }

    enum Mode {
        /// Для экрана "Мероприятия"
        case regular
        /// Для детальной страницы площадки
        case selectedSportsGround(SportsGround)
    }
}

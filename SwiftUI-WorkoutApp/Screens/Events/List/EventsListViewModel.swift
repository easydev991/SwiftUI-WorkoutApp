//
//  EventsListViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 17.05.2022.
//

import Foundation

final class EventsListViewModel: ObservableObject {
    @Published private(set) var futureEvents = [EventResponse]()
    @Published private(set) var pastEvents = [EventResponse]()
    @Published private(set) var eventInfo = EventResponse.emptyValue
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    func isEmpty(for type: EventType) -> Bool {
        switch type {
        case .future: return futureEvents.isEmpty
        case .past: return pastEvents.isEmpty
        }
    }
    private let oldEvents = Bundle.main.decodeJson(
        [EventResponse].self,
        fileName: "oldEvents.json"
    )

    @MainActor
    func askForEvents(type: EventType, refresh: Bool) async {
        if isLoading && !refresh
            || (type == .future && !futureEvents.isEmpty)
            || (type == .past && !pastEvents.isEmpty)
        { return }
        if !refresh { isLoading.toggle() }
        do {
            let list = try await APIService().getEvents(of: type)
            switch type {
            case .future: futureEvents = list
            case .past: pastEvents = list
            }
        } catch {
            if type == .past {
                pastEvents = oldEvents
            }
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func askForEvent(id: Int, refresh: Bool = false) async {
        if isLoading && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            eventInfo = try await APIService().getEvent(by: id)
        } catch {
            if let pastEvent = oldEvents.first(where: { $0.id == id }) {
                eventInfo = pastEvent
            }
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    func clearErrorMessage() { errorMessage = "" }
}

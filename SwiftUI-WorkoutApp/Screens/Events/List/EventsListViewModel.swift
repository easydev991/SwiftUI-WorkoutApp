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
            || (type == .future && !futureEvents.isEmpty && !refresh)
            || (type == .past && !pastEvents.isEmpty && !refresh)
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

    func clearErrorMessage() { errorMessage = "" }
}

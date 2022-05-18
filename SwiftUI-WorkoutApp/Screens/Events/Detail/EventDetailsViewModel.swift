//
//  EventDetailsViewModel.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 18.05.2022.
//

import Foundation

final class EventDetailsViewModel: ObservableObject {
    private let eventID: Int
    @Published var event = EventResponse.emptyValue
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published var isGoing = false

    init(eventID: Int) {
        self.eventID = eventID
    }

    @MainActor
    func askForEvent(refresh: Bool = false, with defaults: DefaultsService) async {
        if isLoading && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            event = try await APIService().getEvent(by: eventID)
            let isUserGoing = event.participants?.contains(where: { $0.userID == defaults.mainUserID })
            isGoing = isUserGoing.isTrue
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func changeVisitEventStatus(isGoing: Bool, with defaults: DefaultsService) async {
        if isLoading || !defaults.isAuthorized { return }
        isLoading.toggle()
        do {
            let isOk = try await APIService(with: defaults).changeVisitEventStatus(for: eventID, isGoing: isGoing)
            if isOk {
                self.isGoing = isGoing
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

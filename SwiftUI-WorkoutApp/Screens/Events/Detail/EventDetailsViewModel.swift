import Foundation

final class EventDetailsViewModel: ObservableObject {
    @Published var event: EventResponse
    @Published private(set) var isDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published var isGoing = false

    init(with event: EventResponse) {
        self.event = event
    }

    @MainActor
    func askForEvent(with defaults: DefaultsService, refresh: Bool) async {
        if isLoading && !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        do {
            event = try await APIService().getEvent(by: event.id)
            let isUserGoing = event.participantsOptional?.contains(where: { $0.userID == defaults.mainUserID })
            isGoing = isUserGoing.isTrue
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func changeIsGoingToEvent(isGoing: Bool, with defaults: DefaultsService) async {
        if isLoading || !defaults.isAuthorized { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).changeIsGoingToEvent(for: event.id, isGoing: isGoing) {
                self.isGoing = isGoing
                if isGoing, let userInfo = defaults.mainUserInfo {
                    event.participants.append(userInfo)
                } else {
                    event.participants.removeAll(where: { $0.userID == defaults.mainUserID })
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func delete(commentID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteComment(from: .event(id: event.id), commentID: commentID) {
                event.comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    @MainActor
    func deleteEvent(_ id: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isDeleted = try await APIService(with: defaults).delete(eventID: id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

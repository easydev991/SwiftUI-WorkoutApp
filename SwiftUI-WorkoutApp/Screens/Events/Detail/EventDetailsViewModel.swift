import Foundation

final class EventDetailsViewModel: ObservableObject {
    @Published var event: EventResponse
    @Published private(set) var isDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init(with event: EventResponse) {
        self.event = event
    }

    @MainActor
    func askForEvent(with defaults: DefaultsService, refresh: Bool) async {
        if (isLoading || event.isFull) && !refresh {
            return
        }
        if !refresh { isLoading.toggle() }
        do {
            event = try await APIService().getEvent(by: event.id)
            let isUserGoing = event.participants.contains(where: { $0.userID == defaults.mainUserID })
            event.trainHere = isUserGoing
        } catch {
            errorMessage = error.localizedDescription
        }
        if !refresh { isLoading.toggle() }
    }

    @MainActor
    func changeIsGoingToEvent(with defaults: DefaultsService) async {
        if isLoading || !defaults.isAuthorized { return }
        isLoading.toggle()
        do {
            let trainHere = !event.trainHere
            if try await APIService(with: defaults).changeIsGoingToEvent(
                for: event.id,
                isGoing: trainHere
            ) {
                event.trainHere = trainHere
                if trainHere, let userInfo = defaults.mainUserInfo {
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
    func deleteEvent(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isDeleted = try await APIService(with: defaults).delete(eventID: event.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

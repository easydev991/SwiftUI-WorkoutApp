import Foundation

@MainActor
final class EventDetailsViewModel: ObservableObject {
    @Published var event: EventResponse
    @Published private(set) var isDeleted = false
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    init(with event: EventResponse) {
        self.event = event
    }

    func askForEvent(refresh: Bool, with defaults: DefaultsService) async {
        if (isLoading || event.isFull) && !refresh { return }
        if !refresh { isLoading.toggle() }
        do {
            event = try await APIService(with: defaults).getEvent(by: event.id)
            let isUserGoing = event.participants.contains(where: { $0.userID == defaults.mainUserID })
            event.trainHere = isUserGoing
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

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
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func delete(_ photo: Photo, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deletePhoto(
                from: .event(.init(containerID: event.id, photoID: photo.id))
            ) {
                await askForEvent(refresh: true, with: defaults)
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func delete(commentID: Int, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            if try await APIService(with: defaults).deleteEntry(from: .event(id: event.id), entryID: commentID) {
                event.comments.removeAll(where: { $0.id == commentID} )
            }
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func deleteEvent(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isDeleted = try await APIService(with: defaults).delete(eventID: event.id)
        } catch {
            errorMessage = ErrorFilterService.message(from: error)
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

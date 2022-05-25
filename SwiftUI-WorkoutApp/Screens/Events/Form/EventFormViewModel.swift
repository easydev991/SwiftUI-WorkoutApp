import Foundation

final class EventFormViewModel: ObservableObject {
    @Published var eventInfo: EventForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    private var eventID: Int?

    init(with event: EventResponse? = nil) {
        eventID = event?.id
        eventInfo = .init(event)
    }

    init(with sportsGround: SportsGround) {
        eventInfo = .emptyValue
        eventInfo.sportsGround = sportsGround
    }

    @MainActor
    func saveEvent(mode: EventFormView.Mode, with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isSuccess = try await APIService(with: defaults).saveEvent(eventInfo, eventID: eventID).id != .zero
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

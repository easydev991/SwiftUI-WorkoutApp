import Foundation

final class CreateOrEditEventViewModel: ObservableObject {
    @Published var eventInfo: EventForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false
    private var eventID: Int?

    init(with event: EventResponse?) {
        eventID = event?.id
        eventInfo = .init(event)
    }

    @MainActor
    func saveEvent(mode: CreateOrEditEventView.Mode, with defaults: DefaultsService) async {
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

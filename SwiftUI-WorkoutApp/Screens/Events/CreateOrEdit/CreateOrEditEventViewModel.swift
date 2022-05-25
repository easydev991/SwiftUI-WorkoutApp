import Foundation

final class CreateOrEditEventViewModel: ObservableObject {
    @Published var eventInfo: EventForm
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isSuccess = false

    init(with event: EventResponse?) {
        eventInfo = .init(event)
    }

    @MainActor
    func saveEvent(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
            isSuccess = try await APIService(with: defaults).createEvent(eventInfo).id != .zero
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }

    func clearErrorMessage() { errorMessage = "" }
}

import Foundation

final class CreateEventViewModel: ObservableObject {
    @Published var eventName = ""
    @Published var eventDate = Date()
    @Published var eventDescription = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""
    @Published private(set) var isEventCreated = false

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

    func createEventAction(with defaults: DefaultsService) async {
        if isLoading { return }
        isLoading.toggle()
        do {
#warning("TODO: интеграция с сервером")
            isEventCreated.toggle()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading.toggle()
    }
}

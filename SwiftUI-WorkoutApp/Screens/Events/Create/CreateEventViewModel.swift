import Foundation

final class CreateEventViewModel: ObservableObject {
    @Published var eventName = ""
    @Published var eventDate = Date()
    @Published var eventDescription = ""
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

    func createEventAction() {
#warning("TODO: интеграция с сервером")
        isEventCreated.toggle()
    }

    func eventAlertClosed() {
        eventName = ""
        eventDate = .now
        eventDescription = ""
        isEventCreated.toggle()
    }
}

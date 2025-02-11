import EventKit
import EventKitUI
import SwiftUI
import SWModels

/// Обертка для стандартного календаря - `EKEventEditViewController`
struct EKEventEditViewControllerRepresentable: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let eventStore: EKEventStore
    let event: EventResponse

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.editViewDelegate = context.coordinator
        let eventDate = event.eventBeginDateForCalendar
        let ekevent = EKEvent(eventStore: eventStore)
        ekevent.title = event.formattedTitle
        ekevent.startDate = eventDate
        ekevent.endDate = eventDate.addingTimeInterval(3600) // +1 час
        ekevent.calendar = eventStore.defaultCalendarForNewEvents
        ekevent.location = event.fullAddress
        ekevent.notes = event.formattedDescription
        ekevent.url = event.shareLinkURL
        ekevent.addAlarm(.init(relativeOffset: -3600)) // Напоминание за 1 час
        controller.event = ekevent
        return controller
    }

    func updateUIViewController(_: EKEventEditViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator { .init(parent: self) }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        private let parent: EKEventEditViewControllerRepresentable

        init(parent: EKEventEditViewControllerRepresentable) {
            self.parent = parent
        }

        @MainActor
        func eventEditViewController(_: EKEventEditViewController, didCompleteWith _: EKEventEditViewAction) {
            parent.dismiss()
        }
    }
}

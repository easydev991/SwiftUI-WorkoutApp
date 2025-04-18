import EventKit
import Foundation

final class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    @Published var showCalendar = false
    @Published var showSettingsAlert = false

    @MainActor
    func requestAccess() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess: showCalendar = true
        case .restricted, .denied: showSettingsAlert = true
        default:
            eventStore.requestAccess(to: .event) { [weak self] granted, _ in
                DispatchQueue.main.async {
                    self?.showCalendar = granted
                    self?.showSettingsAlert = !granted
                }
            }
        }
    }
}

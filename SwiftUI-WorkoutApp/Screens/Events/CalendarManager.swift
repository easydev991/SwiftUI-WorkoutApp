@preconcurrency import EventKit
import Foundation

final class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    @Published var showCalendar = false
    @Published var showSettingsAlert = false

    @MainActor
    func requestAccess() async throws {
        let grantedAccess = if #available(iOS 17.0, *) {
            try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            try await eventStore.requestAccess(to: .event)
        }
        if grantedAccess {
            showCalendar = true
        } else {
            showSettingsAlert = true
        }
    }
}

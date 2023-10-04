import Foundation
import SWModels
import SWNetworkClient

#warning("Лишняя вьюмодель")
@MainActor
final class EventsListViewModel: ObservableObject {
    @Published var futureEvents = [EventResponse]()
    @Published var pastEvents = [EventResponse]()
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage = ""

    func askForEvents(type: EventType, refresh: Bool, with defaults: DefaultsProtocol) async {
        if isLoading && !refresh
            || (type == .future && !futureEvents.isEmpty && !refresh)
            || (type == .past && !pastEvents.isEmpty && !refresh)
        { return }
        if !refresh { isLoading.toggle() }
        do {
            let list = try await SWClient(with: defaults, needAuth: false).getEvents(of: type)
            switch type {
            case .future: futureEvents = list
            case .past: pastEvents = list
            }
        } catch {
            if type == .past {
                setupOldEventsFromBundle()
            }
            errorMessage = ErrorFilter.message(from: error)
        }
        if !refresh { isLoading.toggle() }
    }

    func clearErrorMessage() { errorMessage = "" }
}

private extension EventsListViewModel {
    func setupOldEventsFromBundle() {
        do {
            let oldEvents = try Bundle.main.decodeJson(
                [EventResponse].self,
                fileName: "oldEvents",
                extension: "json"
            )
            pastEvents = oldEvents
        } catch {
            errorMessage = ErrorFilter.message(from: error)
        }
    }
}

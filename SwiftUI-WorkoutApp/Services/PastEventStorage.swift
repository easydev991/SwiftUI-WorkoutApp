import Foundation
import SWModels
import SWUtils

/// Обертка над хранилищем прошедших мероприятий
struct PastEventStorage {
    private let storage: SWFileManager

    init(storage: SWFileManager = SWFileManagerImp(fileName: "OldEvents.json")) {
        self.storage = storage
    }

    /// Прошедшие мероприятия в памяти приложения
    var savedPastEvents: [EventResponse] {
        if let list: [EventResponse] = try? storage.get() {
            list
        } else {
            []
        }
    }

    /// Сохраняет прошедшие мероприятия, если нужно
    func saveIfNeeded(_ events: [EventResponse]) {
        if savedPastEvents.isEmpty {
            try? storage.save(events.sortedByDate)
        } else {
            let savedIds = Set(savedPastEvents.map(\.id))
            let newEvents = events.filter { !savedIds.contains($0.id) }
            guard !newEvents.isEmpty else { return }
            let combinedEvents = newEvents + savedPastEvents
            try? storage.save(combinedEvents.sortedByDate)
        }
    }

    /// Если список прошедших событий на экране пуст,
    /// загружает прошедшие события из памяти
    func loadIfNeeded(_ pastEventsShown: inout [EventResponse]) {
        guard pastEventsShown.isEmpty else { return }
        pastEventsShown = savedPastEvents
    }
}

import Foundation
import SWModels
import SWUtils

/// Обертка над хранилищем прошедших мероприятий
struct PastEventStorage {
    private let storage = SWFileManagerImp(fileName: "OldEvents.json")

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
            try? storage.save(events)
        } else {
            let needToSave = !savedPastEvents.contains(events)
            guard needToSave else { return }
            try? storage.save(events)
        }
    }

    /// Если список прошедших событий на экране пуст,
    /// загружает прошедшие события из памяти
    func loadIfNeeded(_ pastEventsShown: inout [EventResponse]) {
        guard pastEventsShown.isEmpty else { return }
        pastEventsShown = savedPastEvents
    }
}

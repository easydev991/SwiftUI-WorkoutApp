import FileManager991
import Foundation
import SWModels

/// Обертка над хранилищем прошедших мероприятий
struct PastEventStorage {
    private let storage = FileManager991(fileName: "OldEvents.json")

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
            let needToSave: Bool = if #available(iOS 16.0, *) {
                !savedPastEvents.contains(events)
            } else {
                !events.allSatisfy { event in
                    savedPastEvents.contains(where: { $0.id == event.id })
                }
            }
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

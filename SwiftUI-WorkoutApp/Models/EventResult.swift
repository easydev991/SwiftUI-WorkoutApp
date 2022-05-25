import Foundation

/// Результат создания/сохранения мероприятия
struct EventResult: Codable, Equatable {
#warning("TODO: когда на бэке поправят формат данных в ответе по полю area_id, заменить эту модель на EventResponse")
    let id: Int
}

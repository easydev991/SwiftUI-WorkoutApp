import Foundation

/// Результат создания/сохранения мероприятия
struct EventResult: Codable, Equatable {
#warning("Бэк присылает неправильный формат данных в ответе по полю area_id, иначе заменил бы эту модель на EventResponse")
    let id: Int
}

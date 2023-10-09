/// Результат создания/сохранения мероприятия
///
/// Бэк присылает неправильный формат данных в ответе по полю `area_id`.
/// Иначе заменил бы эту модель на `EventResponse`
public struct EventResult: Codable, Equatable {
    public let id: Int
}

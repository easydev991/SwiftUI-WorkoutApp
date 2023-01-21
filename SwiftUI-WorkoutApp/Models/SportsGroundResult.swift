import Foundation

/// Результат создания/сохранения площадки
///
/// Бэк присылает неправильный формат данных в ответе по полям city_id, country_id, type_id, class_id.
/// Иначе заменил бы эту модель на SportsGround
struct SportsGroundResult: Codable, Equatable {
    let id: Int
}

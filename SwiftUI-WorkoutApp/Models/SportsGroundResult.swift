import Foundation

/// Результат создания/сохранения площадки
struct SportsGroundResult: Codable, Equatable {
#warning("Бэк присылает неправильный формат данных в ответе по полям city_id, country_id, type_id, class_id, иначе заменил бы эту модель на SportsGround")
    let id: Int
}

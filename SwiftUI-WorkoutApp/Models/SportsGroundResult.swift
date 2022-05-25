import Foundation

/// Результат создания/сохранения площадки
struct SportsGroundResult: Codable, Equatable {
#warning("TODO: когда на бэке поправят формат данных в ответе по полям city_id, type_id, class_id, заменить эту модель на SportsGround")
    let id: Int
}

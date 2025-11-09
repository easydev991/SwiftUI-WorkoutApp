import Foundation
import SWModels

/// Менеджер кэширования площадок для оптимизации производительности
@MainActor
final class ParksCacheManager: ObservableObject {
    @Published private(set) var parks: [Park] = []

    var count: Int { parks.count }

    /// Обновляет кэш, если данные изменились
    /// - Parameter newParks: Новые данные для сравнения и обновления
    /// - Returns: `true` если кэш был обновлен, `false` если обновление не требовалось
    func updateIfNeeded(with newParks: [Park]) -> Bool {
        guard shouldUpdate(with: newParks) else {
            return false
        }
        parks = newParks
        return true
    }
}

private extension ParksCacheManager {
    /// Проверяет, нужно ли обновить кэш на основе новых данных
    func shouldUpdate(with newParks: [Park]) -> Bool {
        // Если кэш пустой, всегда обновляем (первое обновление)
        if parks.isEmpty {
            return true
        }
        let newIdentifiers = Set(newParks.map(\.id))
        let oldIdentifiers = Set(parks.map(\.id))
        return newIdentifiers != oldIdentifiers || parks.count != newParks.count
    }
}

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

    /// Обновляет кэш отфильтрованными площадками, если данные изменились
    /// - Parameters:
    ///   - allParks: Исходный список всех площадок
    ///   - filter: Фильтр по размеру и типу площадок
    ///   - selectedCityId: Опциональный ID выбранного города
    /// - Returns: `true` если кэш был обновлен, `false` если обновление не требовалось
    func updateIfNeeded(
        allParks: [Park],
        filter: ParkFilterModel,
        selectedCityId: Int?
    ) -> Bool {
        let filtered = filterParks(allParks: allParks, filter: filter, selectedCityId: selectedCityId)
        return updateIfNeeded(with: filtered)
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

    /// Фильтрует площадки по размеру, типу и городу
    func filterParks(
        allParks: [Park],
        filter: ParkFilterModel,
        selectedCityId: Int?
    ) -> [Park] {
        let allowedSizeIds = Set(filter.size.map(\.rawValue))
        let allowedTypeIds = Set(filter.grade.map(\.rawValue))
        let regularParks = allParks.filter { park in
            allowedSizeIds.contains(park.sizeId) && allowedTypeIds.contains(park.typeId)
        }
        guard let selectedCityId else {
            return regularParks
        }
        return regularParks.filter { $0.cityId == selectedCityId }
    }
}

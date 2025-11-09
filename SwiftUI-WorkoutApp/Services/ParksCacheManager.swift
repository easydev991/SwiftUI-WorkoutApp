import Foundation
import SwiftUI
import SWModels

/// Менеджер кэширования площадок для оптимизации производительности
@MainActor
final class ParksCacheManager: ObservableObject {
    @Published private(set) var parks: [Park] = []

    var count: Int { parks.count }

    /// Проверяет, нужно ли обновить кэш на основе новых данных
    func shouldUpdate(with newParks: [Park]) -> Bool {
        let newIdentifiers = Set(newParks.map(\.id))
        let oldIdentifiers = Set(parks.map(\.id))
        return newIdentifiers != oldIdentifiers || parks.count != newParks.count
    }

    /// Обновляет кэш новыми данными
    func update(with newParks: [Park]) {
        parks = newParks
    }
}

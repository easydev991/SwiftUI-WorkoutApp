import SwiftUI
import SWModels
import Testing
@testable import WorkoutApp

struct ParksCacheManagerTests {
    // MARK: - Тесты для updateIfNeeded

    @Test("Должен возвращать true и обновлять кэш при первом обновлении")
    @MainActor
    func updateIfNeeded_returnsTrueAndUpdatesCache_onFirstUpdate() {
        let manager = ParksCacheManager()
        let parks = makeParks(ids: [1, 2, 3])
        let result = manager.updateIfNeeded(with: parks)
        #expect(result)
        #expect(manager.parks.count == 3)
        #expect(manager.parks.map(\.id) == [1, 2, 3])
    }

    @Test("Должен возвращать false если данные не изменились")
    @MainActor
    func updateIfNeeded_returnsFalse_whenDataNotChanged() {
        let manager = ParksCacheManager()
        let parks = makeParks(ids: [1, 2, 3])
        _ = manager.updateIfNeeded(with: parks)
        let result = manager.updateIfNeeded(with: parks)
        #expect(!result)
        #expect(manager.parks.count == 3)
    }

    @Test("Должен возвращать true и обновлять кэш если данные изменились")
    @MainActor
    func updateIfNeeded_returnsTrueAndUpdatesCache_whenDataChanged() {
        let manager = ParksCacheManager()
        let initialParks = makeParks(ids: [1, 2, 3])
        _ = manager.updateIfNeeded(with: initialParks)
        let newParks = makeParks(ids: [1, 2, 3, 4])
        let result = manager.updateIfNeeded(with: newParks)
        #expect(result)
        #expect(manager.parks.count == 4)
        #expect(manager.parks.map(\.id) == [1, 2, 3, 4])
    }

    @Test("Должен возвращать true и обновлять кэш пустым массивом если кэш был не пуст")
    @MainActor
    func updateIfNeeded_returnsTrueAndUpdatesCacheWithEmptyArray_whenCacheWasNotEmpty() {
        let manager = ParksCacheManager()
        let initialParks = makeParks(ids: [1, 2, 3])
        _ = manager.updateIfNeeded(with: initialParks)
        let emptyParks: [Park] = []
        let result = manager.updateIfNeeded(with: emptyParks)
        #expect(result)
        #expect(manager.parks.isEmpty)
        #expect(manager.count == 0)
    }

    // MARK: - Тесты для граничных случаев

    @Test("Должен корректно обрабатывать пустой массив")
    @MainActor
    func updateIfNeeded_handlesEmptyArray() {
        let manager = ParksCacheManager()
        let emptyParks: [Park] = []
        let result = manager.updateIfNeeded(with: emptyParks)
        #expect(result)
        let count = manager.count
        #expect(count == 0)
    }

    @Test("Должен корректно обрабатывать большие массивы (9000+ элементов)")
    @MainActor
    func updateIfNeeded_handlesLargeArrays() {
        let manager = ParksCacheManager()
        let largeParks = makeParks(ids: Array(1 ... 9000))
        let result = manager.updateIfNeeded(with: largeParks)
        #expect(result)
        let count = manager.count
        #expect(count == 9000)
    }
}

// MARK: - Вспомогательные функции

private extension ParksCacheManagerTests {
    func makeParks(ids: [Int]) -> [Park] {
        ids.map { id in
            Park(
                id: id,
                typeId: 1,
                sizeId: 1,
                address: nil,
                author: nil,
                cityId: nil,
                commentsCount: nil,
                createDate: nil,
                latitude: "55.7558",
                longitude: "37.6173",
                name: nil,
                photosOptional: nil,
                preview: nil,
                usersTrainHereCount: nil,
                commentsOptional: nil,
                usersTrainHere: nil,
                trainHere: nil
            )
        }
    }
}

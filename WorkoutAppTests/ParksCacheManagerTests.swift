import SwiftUI
@testable import SwiftUI_WorkoutApp
import SWModels
import Testing

struct ParksCacheManagerTests {
    // MARK: - Тесты для shouldUpdate

    @Test("Должен возвращать true при первом обновлении (кэш пустой)")
    @MainActor
    func shouldUpdate_returnsTrue_whenCacheIsEmpty() {
        let manager = ParksCacheManager()
        let parks = makeParks(ids: [1, 2, 3])
        let result = manager.shouldUpdate(with: parks)
        #expect(result)
    }

    @Test("Должен возвращать false если идентификаторы не изменились")
    @MainActor
    func shouldUpdate_returnsFalse_whenIdentifiersNotChanged() {
        let manager = ParksCacheManager()
        let parks = makeParks(ids: [1, 2, 3])
        manager.update(with: parks)
        let result = manager.shouldUpdate(with: parks)
        #expect(!result)
    }

    @Test("Должен возвращать true если изменились идентификаторы (добавлены новые)")
    @MainActor
    func shouldUpdate_returnsTrue_whenNewIdentifiersAdded() {
        let manager = ParksCacheManager()
        let initialParks = makeParks(ids: [1, 2, 3])
        manager.update(with: initialParks)
        let newParks = makeParks(ids: [1, 2, 3, 4])
        let result = manager.shouldUpdate(with: newParks)
        #expect(result)
    }

    @Test("Должен возвращать true если изменились идентификаторы (удалены старые)")
    @MainActor
    func shouldUpdate_returnsTrue_whenIdentifiersRemoved() {
        let manager = ParksCacheManager()
        let initialParks = makeParks(ids: [1, 2, 3])
        manager.update(with: initialParks)
        let newParks = makeParks(ids: [1, 2])
        let result = manager.shouldUpdate(with: newParks)
        #expect(result)
    }

    @Test("Должен возвращать true если изменилось количество при тех же идентификаторах")
    @MainActor
    func shouldUpdate_returnsTrue_whenCountChangedWithSameIdentifiers() {
        let manager = ParksCacheManager()
        let initialParks = makeParks(ids: [1, 2, 3])
        manager.update(with: initialParks)
        let newParks = makeParks(ids: [1, 2, 3, 1, 2])
        let result = manager.shouldUpdate(with: newParks)
        #expect(result)
    }

    @Test("Должен возвращать true если изменились идентификаторы при том же количестве")
    @MainActor
    func shouldUpdate_returnsTrue_whenIdentifiersChangedWithSameCount() {
        let manager = ParksCacheManager()
        let initialParks = makeParks(ids: [1, 2, 3])
        manager.update(with: initialParks)
        let newParks = makeParks(ids: [4, 5, 6])
        let result = manager.shouldUpdate(with: newParks)
        #expect(result)
    }

    // MARK: - Тесты для update

    @Test("Должен обновлять кэш новыми данными")
    @MainActor
    func update_updatesCacheWithNewData() {
        let manager = ParksCacheManager()
        let parks = makeParks(ids: [1, 2, 3])
        manager.update(with: parks)
        let cachedParks = manager.parks
        #expect(cachedParks.count == 3)
        #expect(cachedParks.map(\.id) == [1, 2, 3])
    }

    @Test("Должен обновлять count после обновления")
    @MainActor
    func update_updatesCountAfterUpdate() {
        let manager = ParksCacheManager()
        let parks = makeParks(ids: [1, 2, 3, 4, 5])
        manager.update(with: parks)
        let count = manager.count
        #expect(count == 5)
    }

    // MARK: - Тесты для граничных случаев

    @Test("Должен корректно обрабатывать пустой массив")
    @MainActor
    func shouldUpdate_handlesEmptyArray() {
        let manager = ParksCacheManager()
        let emptyParks: [Park] = []
        let result = manager.shouldUpdate(with: emptyParks)
        #expect(result)
        manager.update(with: emptyParks)
        let count = manager.count
        #expect(count == 0)
    }

    @Test("Должен корректно обрабатывать большие массивы (9000+ элементов)")
    @MainActor
    func shouldUpdate_handlesLargeArrays() {
        let manager = ParksCacheManager()
        let largeParks = makeParks(ids: Array(1 ... 9000))
        let result = manager.shouldUpdate(with: largeParks)
        #expect(result)
        manager.update(with: largeParks)
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

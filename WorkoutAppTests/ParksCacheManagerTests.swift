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

    // MARK: - Тесты для updateIfNeeded(allParks:filter:selectedCityId:)

    @Test("Должен фильтровать по размеру и типу")
    @MainActor
    func updateIfNeeded_filtersBySizeAndGrade() throws {
        let manager = ParksCacheManager()
        let allParks = [
            makePark(id: 1, sizeId: 1, typeId: 1),
            makePark(id: 2, sizeId: 2, typeId: 1),
            makePark(id: 3, sizeId: 1, typeId: 2),
            makePark(id: 4, sizeId: 3, typeId: 2)
        ]
        let filter = ParkFilterModel(size: [.small], grade: [.soviet])
        let result = manager.updateIfNeeded(allParks: allParks, filter: filter, selectedCityId: nil)
        let firstPark = try #require(manager.parks.first)
        #expect(result)
        #expect(manager.parks.count == 1)
        #expect(firstPark.id == 1)
    }

    @Test("Должен фильтровать по городу если передан selectedCityId")
    @MainActor
    func updateIfNeeded_filtersByCity_whenCityIdProvided() {
        let manager = ParksCacheManager()
        let allParks = [
            makePark(id: 1, sizeId: 1, typeId: 1, cityId: 1),
            makePark(id: 2, sizeId: 1, typeId: 1, cityId: 2),
            makePark(id: 3, sizeId: 1, typeId: 1, cityId: 1)
        ]
        let filter = ParkFilterModel()
        let result = manager.updateIfNeeded(allParks: allParks, filter: filter, selectedCityId: 1)
        #expect(result)
        #expect(manager.parks.count == 2)
        #expect(manager.parks.map(\.id).sorted() == [1, 3])
    }

    @Test("Должен возвращать false если отфильтрованные данные не изменились")
    @MainActor
    func updateIfNeeded_returnsFalse_whenFilteredDataNotChanged() {
        let manager = ParksCacheManager()
        let allParks = [
            makePark(id: 1, sizeId: 1, typeId: 1),
            makePark(id: 2, sizeId: 2, typeId: 1)
        ]
        let filter = ParkFilterModel(size: [.small], grade: [.soviet])
        _ = manager.updateIfNeeded(allParks: allParks, filter: filter, selectedCityId: nil)
        let result = manager.updateIfNeeded(allParks: allParks, filter: filter, selectedCityId: nil)
        #expect(!result)
        #expect(manager.parks.count == 1)
    }

    @Test("Должен возвращать true и обновлять кэш если отфильтрованные данные изменились")
    @MainActor
    func updateIfNeeded_returnsTrueAndUpdatesCache_whenFilteredDataChanged() {
        let manager = ParksCacheManager()
        let initialParks = [
            makePark(id: 1, sizeId: 1, typeId: 1),
            makePark(id: 2, sizeId: 2, typeId: 1)
        ]
        let filter = ParkFilterModel(size: [.small], grade: [.soviet])
        _ = manager.updateIfNeeded(allParks: initialParks, filter: filter, selectedCityId: nil)
        let newParks = [
            makePark(id: 1, sizeId: 1, typeId: 1),
            makePark(id: 2, sizeId: 2, typeId: 1),
            makePark(id: 3, sizeId: 1, typeId: 1)
        ]
        let result = manager.updateIfNeeded(allParks: newParks, filter: filter, selectedCityId: nil)
        #expect(result)
        #expect(manager.parks.count == 2)
        #expect(manager.parks.map(\.id).sorted() == [1, 3])
    }

    @Test("Должен корректно обрабатывать пустой результат фильтрации")
    @MainActor
    func updateIfNeeded_handlesEmptyFilterResult() {
        let manager = ParksCacheManager()
        let allParks = [
            makePark(id: 1, sizeId: 1, typeId: 1),
            makePark(id: 2, sizeId: 2, typeId: 1)
        ]
        let filter = ParkFilterModel(size: [.large], grade: [.legendary])
        let result = manager.updateIfNeeded(allParks: allParks, filter: filter, selectedCityId: nil)
        #expect(result)
        #expect(manager.parks.isEmpty)
        #expect(manager.count == 0)
    }
}

// MARK: - Вспомогательные функции

private extension ParksCacheManagerTests {
    func makeParks(ids: [Int]) -> [Park] {
        ids.map { id in
            makePark(id: id, sizeId: 1, typeId: 1)
        }
    }

    func makePark(id: Int, sizeId: Int, typeId: Int, cityId: Int? = nil) -> Park {
        Park(
            id: id,
            typeId: typeId,
            sizeId: sizeId,
            address: nil,
            author: nil,
            cityId: cityId,
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

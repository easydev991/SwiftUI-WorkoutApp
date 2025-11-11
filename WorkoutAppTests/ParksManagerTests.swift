import Foundation
import SWModels
import Testing
@testable import WorkoutApp

@MainActor
struct ParksManagerTests {
    @Test("Должен вызывать client.getUpdatedParks с lastParksUpdateDateString")
    func getUpdatedParksCallsClient() async throws {
        let mockStorage = MockSWFileManagerImp()
        let mockClient = MockParksUpdaterClient()
        let manager = ParksManager(storage: mockStorage)
        let expectedDate = manager.lastParksUpdateDateString
        try await manager.getUpdatedParks(client: mockClient)
        let dateString = try #require(mockClient.lastDateString)
        #expect(dateString == expectedDate)
    }

    @Test("Должен обновлять fullList с полученными площадками")
    func getUpdatedParksUpdatesFullList() async throws {
        let mockStorage = MockSWFileManagerImp()
        let mockClient = MockParksUpdaterClient()
        let testPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [testPark]
        let manager = ParksManager(storage: mockStorage)
        try await manager.getUpdatedParks(client: mockClient)
        let foundPark = manager.fullList.first(where: { $0.id == testPark.id })
        #expect(foundPark != nil)
    }

    @Test("Должен устанавливать isLoading в false после завершения")
    func getUpdatedParksSetsLoading() async throws {
        let mockStorage = MockSWFileManagerImp()
        let mockClient = MockParksUpdaterClient()
        let manager = ParksManager(storage: mockStorage)
        #expect(!manager.isLoading)
        try await manager.getUpdatedParks(client: mockClient)
        #expect(!manager.isLoading)
    }

    @Test("Должен обрабатывать ошибки от client")
    func getUpdatedParksHandlesErrors() async {
        let mockStorage = MockSWFileManagerImp()
        let mockClient = MockParksUpdaterClient()
        mockClient.errorToThrow = MockError.demoError
        let manager = ParksManager(storage: mockStorage)
        await #expect(throws: MockError.self) {
            try await manager.getUpdatedParks(client: mockClient)
        }
    }

    // MARK: - manuallyUpdatePark

    @Test("Должен обновлять существующую площадку в fullList")
    func manuallyUpdateParkUpdatesExisting() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let initialPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [initialPark]
        try await manager.getUpdatedParks(client: mockClient)

        let updatedPark = makePark(id: 1, sizeId: 2, typeId: 2)
        try manager.manuallyUpdatePark(updatedPark)

        let foundPark = try #require(manager.fullList.first(where: { $0.id == 1 }))
        #expect(foundPark.sizeId == 2)
        #expect(foundPark.typeId == 2)
    }

    @Test("Должен добавлять новую площадку если её нет в fullList")
    func manuallyUpdateParkAddsNew() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let existingPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [existingPark]
        try await manager.getUpdatedParks(client: mockClient)

        let newPark = makePark(id: 2, sizeId: 2, typeId: 2)
        try manager.manuallyUpdatePark(newPark)

        #expect(manager.fullList.count == 2)
        let foundPark = try #require(manager.fullList.first(where: { $0.id == 2 }))
        #expect(foundPark.id == 2)
    }

    // MARK: - deletePark

    @Test("Должен удалять площадку из fullList")
    func deleteParkRemovesFromList() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park1 = makePark(id: 1, sizeId: 1, typeId: 1)
        let park2 = makePark(id: 2, sizeId: 2, typeId: 2)
        mockClient.parksToReturn = [park1, park2]
        try await manager.getUpdatedParks(client: mockClient)

        try manager.deletePark(with: 1)

        #expect(manager.fullList.count == 1)
        let remainingPark = try #require(manager.fullList.first)
        #expect(remainingPark.id == 2)
    }

    @Test("Должен обрабатывать удаление несуществующей площадки")
    func deleteParkHandlesNonExistent() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [park]
        try await manager.getUpdatedParks(client: mockClient)

        try manager.deletePark(with: 999)

        #expect(manager.fullList.count == 1)
        let remainingPark = try #require(manager.fullList.first)
        #expect(remainingPark.id == 1)
    }

    // MARK: - getParks

    @Test("Должен возвращать площадки по указанным идентификаторам")
    func getParksReturnsFilteredParks() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park1 = makePark(id: 1, sizeId: 1, typeId: 1)
        let park2 = makePark(id: 2, sizeId: 2, typeId: 2)
        let park3 = makePark(id: 3, sizeId: 3, typeId: 3)
        mockClient.parksToReturn = [park1, park2, park3]
        try await manager.getUpdatedParks(client: mockClient)

        let result = try await manager.getParks(ids: [1, 3])

        #expect(result.count == 2)
        #expect(result.contains(where: { $0.id == 1 }))
        #expect(result.contains(where: { $0.id == 3 }))
        #expect(!result.contains(where: { $0.id == 2 }))
    }

    @Test("Должен возвращать пустой массив если площадки не найдены")
    func getParksReturnsEmptyWhenNotFound() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [park]
        try await manager.getUpdatedParks(client: mockClient)

        let result = try await manager.getParks(ids: [999, 1000])

        #expect(result.isEmpty)
    }

    // MARK: - Тесты для сохранения в файл (manuallyUpdatePark)

    @Test("Должен вызывать storage.save при обновлении площадки")
    func manuallyUpdateParkCallsStorageSave() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let initialPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [initialPark]
        try await manager.getUpdatedParks(client: mockClient)

        let updatedPark = makePark(id: 1, sizeId: 2, typeId: 2)
        try manager.manuallyUpdatePark(updatedPark)

        #expect(mockStorage.saveCallCount == 2)
    }

    @Test("Должен вызывать storage.save при добавлении новой площадки")
    func manuallyUpdateParkCallsStorageSaveForNew() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let existingPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [existingPark]
        try await manager.getUpdatedParks(client: mockClient)

        let newPark = makePark(id: 2, sizeId: 2, typeId: 2)
        try manager.manuallyUpdatePark(newPark)

        #expect(mockStorage.saveCallCount == 2)
    }

    @Test("Должен обрабатывать ошибки сохранения при обновлении")
    func manuallyUpdateParkHandlesSaveErrors() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let initialPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [initialPark]
        try await manager.getUpdatedParks(client: mockClient)

        mockStorage.errorToThrow = MockError.demoError
        let updatedPark = makePark(id: 1, sizeId: 2, typeId: 2)
        #expect(throws: MockError.self) {
            try manager.manuallyUpdatePark(updatedPark)
        }
    }

    @Test("Должен передавать правильные данные в storage.save")
    func manuallyUpdateParkSavesCorrectData() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let initialPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [initialPark]
        try await manager.getUpdatedParks(client: mockClient)

        let updatedPark = makePark(id: 1, sizeId: 2, typeId: 2)
        try manager.manuallyUpdatePark(updatedPark)

        let savedData = try #require(mockStorage.savedData as? [Park])
        #expect(savedData.count == 1)
        let savedPark = try #require(savedData.first)
        #expect(savedPark.id == 1)
        #expect(savedPark.sizeId == 2)
        #expect(savedPark.typeId == 2)
    }

    // MARK: - Тесты для сохранения в файл (deletePark)

    @Test("Должен вызывать storage.save при удалении площадки")
    func deleteParkCallsStorageSave() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park1 = makePark(id: 1, sizeId: 1, typeId: 1)
        let park2 = makePark(id: 2, sizeId: 2, typeId: 2)
        mockClient.parksToReturn = [park1, park2]
        try await manager.getUpdatedParks(client: mockClient)

        try manager.deletePark(with: 1)

        #expect(mockStorage.saveCallCount == 2)
    }

    @Test("Должен обрабатывать ошибки сохранения при удалении")
    func deleteParkHandlesSaveErrors() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [park]
        try await manager.getUpdatedParks(client: mockClient)

        mockStorage.errorToThrow = MockError.demoError
        #expect(throws: MockError.self) {
            try manager.deletePark(with: 1)
        }
    }

    @Test("Должен передавать правильные данные в storage.save после удаления")
    func deleteParkSavesCorrectData() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let park1 = makePark(id: 1, sizeId: 1, typeId: 1)
        let park2 = makePark(id: 2, sizeId: 2, typeId: 2)
        mockClient.parksToReturn = [park1, park2]
        try await manager.getUpdatedParks(client: mockClient)

        try manager.deletePark(with: 1)

        let savedData = try #require(mockStorage.savedData as? [Park])
        #expect(savedData.count == 1)
        let savedPark = try #require(savedData.first)
        #expect(savedPark.id == 2)
    }

    // MARK: - Тесты для сохранения в файл (updateDefaultList)

    @Test("Должен вызывать storage.save при обновлении списка")
    func updateDefaultListCallsStorageSave() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let updatedPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [updatedPark]

        try await manager.getUpdatedParks(client: mockClient)

        #expect(mockStorage.saveCallCount == 1)
    }

    @Test("Должен обрабатывать ошибки сохранения при обновлении списка")
    func updateDefaultListHandlesSaveErrors() async {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.errorToThrow = MockError.demoError
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let updatedPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [updatedPark]

        await #expect(throws: MockError.self) {
            try await manager.getUpdatedParks(client: mockClient)
        }
    }

    @Test("Должен обновлять lastParksUpdateDateString после успешного сохранения")
    func updateDefaultListUpdatesDateString() async throws {
        let mockStorage = MockSWFileManagerImp()
        let manager = ParksManager(storage: mockStorage)
        let mockClient = MockParksUpdaterClient()
        let updatedPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [updatedPark]
        let initialDate = manager.lastParksUpdateDateString
        try await Task.sleep(nanoseconds: 100_000_000)

        try await manager.getUpdatedParks(client: mockClient)

        let updatedDate = manager.lastParksUpdateDateString
        #expect(updatedDate != initialDate)
    }

    // MARK: - Тесты для makeDefaultList

    @Test("Должен вызывать storage.get если файл существует")
    func makeDefaultListCallsStorageGetWhenFileExists() async throws {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.documentExists = true
        let testPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockStorage.dataToReturn = [testPark]
        let manager = ParksManager(storage: mockStorage)

        try await manager.makeDefaultList()

        #expect(mockStorage.getCallCount == 1)
        let foundPark = manager.fullList.first(where: { $0.id == 1 })
        #expect(foundPark != nil)
    }

    @Test("Должен использовать Bundle.main.decodeJson если файл не существует")
    func makeDefaultListUsesBundleWhenFileNotExists() async throws {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.documentExists = false
        let manager = ParksManager(storage: mockStorage)

        try await manager.makeDefaultList()

        #expect(mockStorage.getCallCount == 0)
        #expect(!manager.fullList.isEmpty)
    }

    @Test("Должен загружать из Bundle если файл существует, но пустой")
    func makeDefaultListUsesBundleWhenFileIsEmpty() async throws {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.documentExists = true
        mockStorage.dataToReturn = [Park]()
        let manager = ParksManager(storage: mockStorage)

        try await manager.makeDefaultList()

        #expect(mockStorage.getCallCount == 1)
        #expect(!manager.fullList.isEmpty)
    }

    @Test("Должен загружать из Bundle если ошибка при чтении файла")
    func makeDefaultListUsesBundleWhenFileReadError() async throws {
        let mockStorage = MockSWFileManagerImp()
        mockStorage.documentExists = true
        mockStorage.errorToThrow = MockError.demoError
        let manager = ParksManager(storage: mockStorage)

        try await manager.makeDefaultList()

        #expect(mockStorage.getCallCount == 1)
        #expect(!manager.fullList.isEmpty)
    }
}

// MARK: - Вспомогательные функции

private extension ParksManagerTests {
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

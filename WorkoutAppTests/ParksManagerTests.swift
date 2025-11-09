import Foundation
import SWModels
import SWNetworkClient
import Testing
@testable import WorkoutApp

@Suite("ParksManager.getUpdatedParks")
final class ParksManagerTests {
    @Test("Должен вызывать client.getUpdatedParks с правильной датой")
    @MainActor
    func getUpdatedParksCallsClient() async throws {
        let mockClient = MockParksUpdaterClient()
        let manager = ParksManager()
        try await manager.getUpdatedParks(client: mockClient, from: "2025-01-01")
        let dateString = try #require(mockClient.lastDateString)
        #expect(dateString == "2025-01-01")
    }

    @Test("Должен использовать lastParksUpdateDateString если dateString не передан")
    @MainActor
    func getUpdatedParksUsesDefaultDate() async throws {
        let mockClient = MockParksUpdaterClient()
        let manager = ParksManager()
        let expectedDate = manager.lastParksUpdateDateString
        try await manager.getUpdatedParks(client: mockClient, from: nil)
        let dateString = try #require(mockClient.lastDateString)
        #expect(dateString == expectedDate)
    }

    @Test("Должен обновлять fullList с полученными площадками")
    @MainActor
    func getUpdatedParksUpdatesFullList() async throws {
        let mockClient = MockParksUpdaterClient()
        let testPark = makePark(id: 1, sizeId: 1, typeId: 1)
        mockClient.parksToReturn = [testPark]
        let manager = ParksManager()
        try await manager.getUpdatedParks(client: mockClient, from: nil)
        let foundPark = manager.fullList.first(where: { $0.id == testPark.id })
        #expect(foundPark != nil)
    }

    @Test("Должен устанавливать isLoading в false после завершения")
    @MainActor
    func getUpdatedParksSetsLoading() async throws {
        let mockClient = MockParksUpdaterClient()
        let manager = ParksManager()
        #expect(!manager.isLoading)
        try await manager.getUpdatedParks(client: mockClient, from: nil)
        #expect(!manager.isLoading)
    }

    @Test("Должен обрабатывать ошибки от client")
    @MainActor
    func getUpdatedParksHandlesErrors() async {
        let mockClient = MockParksUpdaterClient()
        mockClient.errorToThrow = MockError.demoError
        let manager = ParksManager()
        await #expect(throws: MockError.self) {
            try await manager.getUpdatedParks(client: mockClient, from: nil)
        }
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

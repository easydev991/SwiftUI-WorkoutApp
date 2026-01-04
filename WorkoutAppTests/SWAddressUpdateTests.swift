import Foundation
import SWModels
import Testing
@testable import WorkoutApp

struct SWAddressUpdateTests {
    private let mockStorage = MockSWFileManagerImp()
    private let mockClient = MockCountriesClient()

    @Test("Должен возвращать false если обновление не требуется")
    func shouldReturnFalseWhenUpdateNotNeeded() async throws {
        let recentDate = Date.now
        let address = SWAddress(storage: mockStorage)

        let result = try await address.updateIfNeeded(
            lastUpdateDate: recentDate,
            client: mockClient
        )

        #expect(!result)
        #expect(mockClient.getCountriesCallCount == 0)
    }

    @Test("Должен обновлять справочник если требуется обновление")
    func shouldUpdateWhenUpdateNeeded() async throws {
        let oldDate = oldUpdateDate
        let testCountry = try makeTestCountry()
        mockClient.mockedCountries = [testCountry]
        let address = SWAddress(storage: mockStorage)

        let result = try await address.updateIfNeeded(
            lastUpdateDate: oldDate,
            client: mockClient
        )

        #expect(result)
        #expect(mockClient.getCountriesCallCount == 1)
        #expect(mockStorage.saveCallCount == 1)
        let savedData = try #require(mockStorage.savedData as? [Country])
        let firstCountry = try #require(savedData.first)
        #expect(savedData.count == 1)
        #expect(firstCountry.id == testCountry.id)
    }

    @Test("Должен пробрасывать ошибку при ошибке загрузки")
    func shouldThrowErrorOnLoadError() async throws {
        let oldDate = oldUpdateDate
        mockClient.shouldThrowError = true
        let address = SWAddress(storage: mockStorage)

        await #expect(throws: MockCountriesClient.MockError.self) {
            try await address.updateIfNeeded(
                lastUpdateDate: oldDate,
                client: mockClient
            )
        }
    }

    @Test("Должен использовать storage из экземпляра")
    func shouldUseStorageFromInstance() async throws {
        let oldDate = oldUpdateDate
        let testCountry = try makeTestCountry()
        mockClient.mockedCountries = [testCountry]
        let address = SWAddress(storage: mockStorage)

        _ = try await address.updateIfNeeded(
            lastUpdateDate: oldDate,
            client: mockClient
        )

        #expect(mockStorage.saveCallCount == 1)
        let savedData = try #require(mockStorage.savedData as? [Country])
        #expect(savedData.count == 1)
    }

    @Test("Должен пробрасывать ошибку при ошибке сохранения")
    func shouldThrowErrorOnSaveError() async throws {
        let oldDate = oldUpdateDate
        let saveError = NSError(domain: "TestError", code: 1)
        mockStorage.errorToThrow = saveError
        let testCountry = try makeTestCountry()
        mockClient.mockedCountries = [testCountry]
        let address = SWAddress(storage: mockStorage)

        await #expect(throws: Error.self) {
            try await address.updateIfNeeded(
                lastUpdateDate: oldDate,
                client: mockClient
            )
        }
    }
}

private extension SWAddressUpdateTests {
    /// Дата обновления, которая требует обновления справочника (2 дня назад)
    var oldUpdateDate: Date {
        Date.now.addingTimeInterval(-2 * 24 * 60 * 60)
    }

    func makeTestCountry() throws -> Country {
        let json = """
        {
            "id": "1",
            "name": "Тестовая страна",
            "cities": []
        }
        """
        let data = try #require(json.data(using: .utf8))
        return try JSONDecoder().decode(Country.self, from: data)
    }
}

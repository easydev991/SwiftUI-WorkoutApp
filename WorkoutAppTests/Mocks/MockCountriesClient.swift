import Foundation
import SWModels
import SWNetworkClient

final class MockCountriesClient: CountriesClient, @unchecked Sendable {
    var mockedCountries: [Country] = []
    var shouldThrowError = false
    var errorToThrow: Error = MockCountriesClient.MockError.demoError
    var getCountriesCallCount = 0
    var delay: TimeInterval = 0

    init(mockedCountries: [Country] = []) {
        self.mockedCountries = mockedCountries
    }

    func getCountries() async throws -> [Country] {
        getCountriesCallCount += 1
        if delay > 0 {
            try await Task.sleep(for: .seconds(delay))
        }
        if shouldThrowError {
            throw errorToThrow
        }
        return mockedCountries
    }
}

extension MockCountriesClient {
    /// Ошибка для тестирования
    enum MockError: Error {
        case demoError
    }
}

import Foundation
import SWModels
import SWNetworkClient
import Testing

/// Ошибка для тестирования
enum MockError: Error {
    case demoError
}

/// Мок-клиент для тестирования ParksManager.getUpdatedParks
final class MockParksUpdaterClient: @unchecked Sendable, ParksUpdaterClient {
    var parksToReturn: [Park] = []
    var errorToThrow: Error?
    var lastDateString: String?

    func getUpdatedParks(from stringDate: String) async throws -> [Park] {
        lastDateString = stringDate
        if let error = errorToThrow {
            throw error
        }
        return parksToReturn
    }
}

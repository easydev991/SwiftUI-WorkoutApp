import Foundation
import SWUtils
import Testing

/// Мок-реализация SWFileManager для тестирования
final class MockSWFileManagerImp: @unchecked Sendable, SWFileManager {
    var documentExists = false
    var savedData: Any?
    var dataToReturn: Any?
    var errorToThrow: Error?
    var saveCallCount = 0
    var getCallCount = 0

    func save(_ object: some Encodable) throws {
        saveCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        savedData = object
    }

    func get<T: Decodable>() throws -> T {
        getCallCount += 1
        if let error = errorToThrow {
            throw error
        }
        guard let result = dataToReturn as? T else {
            throw NSError(
                domain: "MockSWFileManagerImp",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to cast dataToReturn to requested type"]
            )
        }
        return result
    }
}

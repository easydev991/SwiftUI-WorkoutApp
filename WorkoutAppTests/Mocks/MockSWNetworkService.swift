import Foundation
import SWNetwork

final class MockSWNetworkService: NetworkServicing, @unchecked Sendable {
    var errorToThrow: Error?

    func requestData<T: Decodable>(components _: RequestComponents) async throws -> T {
        if let errorToThrow {
            throw errorToThrow
        }
        throw MockError.noDataConfigured
    }

    func requestStatus(components _: RequestComponents) async throws {
        if let errorToThrow {
            throw errorToThrow
        }
    }
}

extension MockSWNetworkService {
    /// Ошибка для тестирования
    enum MockError: Error {
        case noDataConfigured
    }
}

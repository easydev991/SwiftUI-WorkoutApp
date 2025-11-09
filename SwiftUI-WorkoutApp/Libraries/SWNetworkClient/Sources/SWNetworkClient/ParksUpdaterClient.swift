import Foundation
import SWModels

/// Протокол для загрузки обновленных площадок
public protocol ParksUpdaterClient: Sendable {
    /// Загружает список всех площадок, обновленных после указанной даты
    /// - Parameter stringDate: дата отсечки для поиска обновленных площадок
    /// - Returns: Список обновленных площадок
    func getUpdatedParks(from stringDate: String) async throws -> [Park]
}

extension SWClient: ParksUpdaterClient {
    /// Загружает список всех площадок, обновленных после указанной даты
    /// - Parameter stringDate: дата отсечки для поиска обновленных площадок
    /// - Returns: Список обновленных площадок
    public func getUpdatedParks(from stringDate: String) async throws -> [Park] {
        let endpoint = Endpoint.getUpdatedParks(from: stringDate)
        return try await makeResult(for: endpoint)
    }
}

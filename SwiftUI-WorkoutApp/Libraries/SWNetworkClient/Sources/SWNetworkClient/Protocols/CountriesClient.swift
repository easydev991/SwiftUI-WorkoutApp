import Foundation
import SWModels

/// Протокол для работы со справочником стран/городов
public protocol CountriesClient: Sendable {
    /// Загружает справочник стран/городов
    /// - Returns: Справочник стран/городов
    func getCountries() async throws -> [Country]
}

extension SWClient: CountriesClient {
    public func getCountries() async throws -> [Country] {
        let endpoint = Endpoint.getCountries
        return try await makeResult(for: endpoint)
    }
}

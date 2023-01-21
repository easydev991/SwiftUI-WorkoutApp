import Foundation
import Utils

public protocol ShortAddressProtocol {
    /// Адрес в формате "Страна, Город"
    var address: String { get }
    /// Широта и долгота
    var coordinates: (Double, Double) { get }
    /// Название города
    var cityName: String? { get }
}

public struct ShortAddressService {
    /// `id` страны
    private let countryID: Int
    /// `id` города
    private let cityID: Int

    /// Инициализирует `ShortAddressService`
    /// - Parameters:
    ///   - countryID: `id` страны
    ///   - cityID: `id` города
    public init(_ countryID: Int, _ cityID: Int) {
        self.countryID = countryID
        self.cityID = cityID
    }
}

extension ShortAddressService: ShortAddressProtocol {    
    public var address: String {
        guard countryID != .zero, cityID != .zero,
              let country = try? countries().first(where: { $0.id == String(countryID) })
        else { return "" }
        if let cityName = country.cities.first(where: { $0.id == String(cityID) })?.name {
            return country.name + ", " + cityName
        } else {
            return country.name
        }
    }

    public var coordinates: (Double, Double) {
        guard countryID != .zero, cityID != .zero,
              let city = try? city(with: cityID, in: countryID),
              let latitude = Double(city.lat),
              let longitude = Double(city.lon)
        else { return (.zero, .zero) }
        return (latitude, longitude)
    }

    public var cityName: String? {
        try? city(with: cityID, in: countryID)?.name
    }
}

private extension ShortAddressService {
    func countries() throws -> [Country] {
        try Bundle.main.decodeJson([Country].self, fileName: "countries", extension: "json")
    }

    func city(with id: Int, in countryID: Int) throws -> City? {
        let country = try countries().first(where: { $0.id == String(countryID) })
        return country?.cities.first(where: { $0.id == String(id) })
    }
}

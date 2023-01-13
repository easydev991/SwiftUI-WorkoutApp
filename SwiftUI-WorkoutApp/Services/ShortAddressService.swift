import Foundation

protocol ShortAddressProtocol {
    func addressFor(_ countryID: Int, _ cityID: Int) -> String
    func coordinates(_ countryID: Int, _ cityID: Int) -> (Double, Double)
}

struct ShortAddressService: ShortAddressProtocol {
    func addressFor(_ countryID: Int, _ cityID: Int) -> String {
        guard countryID != .zero, cityID != .zero,
              let country = try? countries().first(where: { $0.id == String(countryID) })
        else { return "" }
        let countryName = country.name
        if let cityName = country.cities.first(where: { $0.id == String(cityID) })?.name {
            return countryName + ", " + cityName
        } else {
            return countryName
        }
    }

    func coordinates(_ countryID: Int, _ cityID: Int) -> (Double, Double) {
        guard countryID != .zero, cityID != .zero,
              let city = try? city(with: cityID, in: countryID)
        else { return (.zero, .zero) }
        let lat = Double(city.lat) ?? .zero
        let lon = Double(city.lon) ?? .zero
        return (lat, lon)
    }
}

extension ShortAddressService {
    func cityName(with id: Int, in countryID: Int) throws -> String? {
        try city(with: id, in: countryID)?.name
    }
}

private extension ShortAddressService {
    func countries() throws -> [Country] {
        try Bundle.main.decodeJson(
            [Country].self,
            fileName: "countries.json"
        )
    }

    func city(with id: Int, in countryID: Int) throws -> City? {
        let country = try countries().first(where: { $0.id == String(countryID) })
        return country?.cities.first(where: { $0.id == String(id) })
    }
}

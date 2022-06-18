import Foundation

struct ShortAddressService {
    func addressFor(_ countryID: Int, _ cityID: Int) -> String {
        do {
            let country = try countries().first(where: { $0.id == String(countryID) })
            let city = country?.cities.first(where: { $0.id == String(cityID) })
            let countryName = (country?.name).valueOrEmpty
            if let cityName = city?.name {
                return countryName + ", " + cityName
            } else {
                return countryName
            }
        } catch {
            return ""
        }
    }

    func coordinates(_ countryID: Int, _ cityID: Int) -> (Double, Double) {
        do {
            let city = try city(with: cityID, in: countryID)
            let lat = Double(city.lat) ?? .zero
            let lon = Double(city.lon) ?? .zero
            return (lat, lon)
        } catch {
            let defaultCity = City.defaultCity
            let lat = Double(defaultCity.lat) ?? .zero
            let lon = Double(defaultCity.lon) ?? .zero
            return (lat, lon)
        }
    }
}

private extension ShortAddressService {
    func countries() throws -> [Country] {
        try Bundle.main.decodeJson(
            [Country].self,
            fileName: "countries.json"
        )
    }

    func city(with id: Int, in countryID: Int) throws -> City {
        do {
            let country = try countries().first(where: { $0.id == String(countryID) })
            return country?.cities.first(where: { $0.id == String(id) }) ?? .defaultCity
        } catch {
            return .defaultCity
        }
    }
}

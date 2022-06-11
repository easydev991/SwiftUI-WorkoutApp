import Foundation
import Utils

struct ShortAddressService {
    func addressFor(_ countryID: Int, _ cityID: Int) -> String {
        do {
            let countries = try Bundle.main.decodeJson(
                [Country].self,
                fileName: "countries.json"
            )
            let country = countries.first(where: { $0.id == String(countryID) })
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
}

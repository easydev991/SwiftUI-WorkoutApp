import CoreLocation
import Foundation
import OSLog
import SWModels
import SWUtils

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SWAddress")

/// Модель для работы с адресами и справочником стран/городов
struct SWAddress {
    private static let storage = SWFileManager(fileName: "CountriesAndCities.json")
    private let countryID: Int
    private let cityID: Int

    /// Обычный инициализатор
    /// - Parameters:
    ///   - countryID: `id` страны
    ///   - cityID: `id` города
    init(_ countryID: Int, _ cityID: Int) {
        self.countryID = countryID
        self.cityID = cityID
    }

    /// `Failable`-инициализатор
    /// - Parameters:
    ///   - countryID: `id` страны
    ///   - cityID: `id` города
    init?(_ countryID: Int?, _ cityID: Int?) {
        guard let countryID, let cityID else {
            return nil
        }
        self.init(countryID, cityID)
    }

    /// Инициализатор для обращения к справочнику стран/городов
    init() {
        self.countryID = 0
        self.cityID = 0
    }
}

extension SWAddress {
    /// Страна и город
    var address: String {
        guard countryID != 0, cityID != 0,
              let country = try? Self.countries().first(where: { $0.id == String(countryID) })
        else { return "" }
        if let cityName = country.cities.first(where: { $0.id == String(cityID) })?.name {
            return country.name + ", " + cityName
        } else {
            return country.name
        }
    }

    /// Координаты для страны/города (широта, долгота)
    var coordinate: (Double, Double)? {
        guard countryID != 0, cityID != 0,
              let city = try? Self.city(with: cityID, in: countryID),
              let latitude = Double(city.lat),
              let longitude = Double(city.lon)
        else { return nil }
        return (latitude, longitude)
    }

    /// Название города
    var cityName: String? {
        do {
            return try Self.city(with: cityID, in: countryID)?.name
        } catch {
            logger.error("Не смогли получить название города, \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Сохраняет список стран/городов в памяти девайса
    ///
    /// - Parameter countries: Страны/города для сохранения
    func save(_ countries: [Country]) throws {
        try Self.storage.save(countries)
        logger.debug("Успешно сохранили список стран (\(countries.count) шт.)")
    }
}

extension SWAddress {
    /// Проверяет, нужно ли обновлять справочник стран/городов
    ///
    /// По статистике Антона справочник на сервере обновляется в среднем раз в месяц
    /// - Parameter lastUpdateDate: Дата предыдущего успешного обновления справочника
    /// - Returns: `true` - нужно обновлять, `false` - не нужно
    func needUpdate(_ lastUpdateDate: Date) -> Bool {
        DateFormatterService.days(from: lastUpdateDate, to: .now) > 30
    }

    /// Возвращает сохраненный в памяти справочник стран/городов
    static func countries() throws -> [Country] {
        if storage.documentExists {
            try storage.get()
        } else {
            try Bundle.main.decodeJson(
                [Country].self,
                fileName: "countries",
                extension: "json"
            )
        }
    }

    /// Возвращает сохраненный в памяти список всех городов
    static func cities() throws -> [City] {
        try countries().flatMap(\.cities)
    }

    static func findCity(with name: String) throws -> City {
        let storedCities = try cities()
        guard let storedCity = storedCities.first(where: { $0.name.lowercased() == name.lowercased() }) else {
            throw AddressError.failedToFindCityByName(name)
        }
        return storedCity
    }
}

extension SWAddress {
    enum AddressError: Error, LocalizedError {
        case failedToFindCityByName(String)

        var errorDescription: String? {
            switch self {
            case let .failedToFindCityByName(name):
                "Не удалось найти город \(name)"
            }
        }
    }
}

extension SWAddress {
    /// Пытается создать адрес из отметки на карте
    ///
    /// Используется для адреса новой площадки
    static func makeAddress(for placemark: CLPlacemark) -> String? {
        let components = [
            placemark.country,
            placemark.administrativeArea,
            placemark.subAdministrativeArea,
            placemark.locality,
            placemark.subLocality,
            placemark.thoroughfare,
            placemark.subThoroughfare
        ].compactMap(\.self)
        // Удаление дубликатов с сохранением порядка
        var uniqueComponents = [String]()
        var seen = Set<String>()
        for component in components {
            guard !seen.contains(component) else { continue }
            seen.insert(component)
            uniqueComponents.append(component)
        }
        return uniqueComponents.isEmpty ? nil : uniqueComponents.joined(separator: ", ")
    }

    /// Пытается создать идентификатор города по точке на карте
    /// - Parameter placemarkLocality: Точка на карте
    /// - Returns: Идентификатор города в случае успеха или `nil`
    static func makeCityId(with placemarkLocality: String?) -> Int? {
        guard let placemarkLocality,
              let city = try? findCity(with: placemarkLocality),
              let cityId = Int(city.id)
        else {
            let message = "Не смогли найти город в справочнике с названием \(placemarkLocality ?? "неизвестно")"
            logger.error("\(message)")
            assertionFailure(message)
            return nil
        }
        return cityId
    }
}

private extension SWAddress {
    static func city(with id: Int, in countryID: Int) throws -> City? {
        let country = try countries().first(where: { $0.id == String(countryID) })
        return country?.cities.first(where: { $0.id == String(id) })
    }
}

import CoreLocation
import Foundation
import OSLog
import SWModels
import SWNetworkClient
import SWUtils

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SWAddress")

/// Модель для работы с адресами и справочником стран/городов
struct SWAddress {
    private static let defaultStorage = SWFileManagerImp(fileName: "CountriesAndCities.json")
    private let storage: SWFileManager
    private let countryId: Int
    private let cityId: Int

    /// Обычный инициализатор
    /// - Parameters:
    ///   - countryId: `id` страны
    ///   - cityId: `id` города
    ///   - storage: Хранилище для справочника стран/городов
    init(_ countryId: Int, _ cityId: Int, storage: SWFileManager = defaultStorage) {
        self.countryId = countryId
        self.cityId = cityId
        self.storage = storage
    }

    /// `Failable`-инициализатор
    /// - Parameters:
    ///   - countryId: `id` страны
    ///   - cityId: `id` города
    ///   - storage: Хранилище для справочника стран/городов
    init?(_ countryId: Int?, _ cityId: Int?, storage: SWFileManager = defaultStorage) {
        guard let countryId, let cityId else {
            return nil
        }
        self.init(countryId, cityId, storage: storage)
    }

    /// Инициализатор для обращения к справочнику стран/городов
    /// - Parameter storage: Хранилище для справочника стран/городов
    init(storage: SWFileManager = defaultStorage) {
        self.countryId = 0
        self.cityId = 0
        self.storage = storage
    }
}

extension SWAddress {
    /// Страна и город
    var address: String {
        guard countryId != 0, cityId != 0,
              let country = try? Self.countries(storage: storage).first(where: { $0.id == String(countryId) })
        else { return "" }
        if let cityName = country.cities.first(where: { $0.id == String(cityId) })?.name {
            return country.name + ", " + cityName
        } else {
            return country.name
        }
    }

    /// Координаты для страны/города (широта, долгота)
    var coordinate: (lat: Double, lon: Double)? {
        guard countryId != 0, cityId != 0,
              let city = try? Self.city(with: cityId, in: countryId, storage: storage),
              let lat = Double(city.lat),
              let lon = Double(city.lon)
        else { return nil }
        return (lat, lon)
    }

    /// Название города
    var cityName: String? {
        do {
            return try Self.city(with: cityId, in: countryId, storage: storage)?.name
        } catch {
            logger.error("Не смогли получить название города, \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Сохраняет список стран/городов в памяти девайса
    ///
    /// - Parameter countries: Страны/города для сохранения
    func save(_ countries: [Country]) throws {
        try storage.save(countries)
        logger.debug("Успешно сохранили список стран (\(countries.count) шт.)")
    }

    /// Обновляет справочник стран/городов при необходимости
    /// - Parameters:
    ///   - lastUpdateDate: Дата предыдущего успешного обновления
    ///   - client: Клиент для загрузки данных со сервера
    /// - Returns: `true` если обновление было выполнено, `false` если не требовалось
    func updateIfNeeded(
        lastUpdateDate: Date,
        client: CountriesClient
    ) async throws -> Bool {
        guard needUpdate(lastUpdateDate) else {
            return false
        }
        let countries = try await client.getCountries()
        try save(countries)
        return true
    }
}

extension SWAddress {
    /// Проверяет, нужно ли обновлять справочник стран/городов
    ///
    /// Обновляем, если прошло больше дня с момента предыдущего обновления
    /// - Parameter lastUpdateDate: Дата предыдущего успешного обновления справочника
    /// - Returns: `true` - нужно обновлять, `false` - не нужно
    func needUpdate(_ lastUpdateDate: Date) -> Bool {
        DateFormatterService.days(from: lastUpdateDate, to: .now) > 1
    }

    /// Возвращает сохраненный в памяти справочник стран/городов
    /// - Parameter storage: Хранилище для справочника стран/городов
    static func countries(storage: SWFileManager = defaultStorage) throws -> [Country] {
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
    /// - Parameter storage: Хранилище для справочника стран/городов
    static func cities(storage: SWFileManager = defaultStorage) throws -> [City] {
        try countries(storage: storage).flatMap(\.cities)
    }

    /// Находит город по названию
    /// - Parameters:
    ///   - name: Название города
    ///   - storage: Хранилище для справочника стран/городов
    static func findCity(with name: String, storage: SWFileManager = defaultStorage) throws -> City {
        let storedCities = try cities(storage: storage)
        guard let storedCity = storedCities.first(where: { $0.name.lowercased() == name.lowercased() }) else {
            throw AddressError.failedToFindCityByName(name)
        }
        return storedCity
    }
}

extension SWAddress {
    enum AddressError: Error, LocalizedError, Equatable {
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
    /// - Parameters:
    ///   - placemarkLocality: Точка на карте
    ///   - storage: Хранилище для справочника стран/городов
    /// - Returns: Идентификатор города в случае успеха или `nil`
    static func makeCityId(with placemarkLocality: String?, storage: SWFileManager = defaultStorage) -> Int? {
        guard let placemarkLocality,
              let city = try? findCity(with: placemarkLocality, storage: storage),
              let cityId = Int(city.id)
        else {
            logger.error("Не смогли найти город в справочнике с названием \(placemarkLocality ?? "неизвестно")")
            return nil
        }
        return cityId
    }
}

private extension SWAddress {
    static func city(with id: Int, in countryId: Int, storage: SWFileManager = defaultStorage) throws -> City? {
        let country = try countries(storage: storage).first(where: { $0.id == String(countryId) })
        return country?.cities.first(where: { $0.id == String(id) })
    }
}

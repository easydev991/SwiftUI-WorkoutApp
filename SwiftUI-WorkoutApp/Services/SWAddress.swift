import CoreLocation
import FileManager991
import Foundation
import OSLog
import SWModels
import Utils

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SWAddress")

/// Модель для работы с адресами и справочником стран/городов
struct SWAddress {
    private let storage = FileManager991(fileName: "CountriesAndCities.json")
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
        self.countryID = countryID
        self.cityID = cityID
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
              let country = try? countries().first(where: { $0.id == String(countryID) })
        else { return "" }
        if let cityName = country.cities.first(where: { $0.id == String(cityID) })?.name {
            return country.name + ", " + cityName
        } else {
            return country.name
        }
    }

    /// Координаты для страны/города (широта, долгота)
    var coordinates: (Double, Double) {
        guard countryID != 0, cityID != 0,
              let city = try? city(with: cityID, in: countryID),
              let latitude = Double(city.lat),
              let longitude = Double(city.lon)
        else { return (0, 0) }
        return (latitude, longitude)
    }

    /// Название города
    var cityName: String? {
        do {
            return try city(with: cityID, in: countryID)?.name
        } catch {
            logger.error("Не смогли получить название города, ошибка: \(error)")
            return nil
        }
    }

    /// Сохраняет список стран/городов в памяти девайса
    ///
    /// - Parameter countries: Страны/города для сохранения
    /// - Returns: `true` в случае успеха, `false` - при неудаче
    func save(_ countries: [Country]) -> Bool {
        do {
            try storage.save(countries)
            logger.info("✅ Успешно сохранили список стран")
            return true
        } catch {
            logger.error("⛔️ Не смогли сохранить список стран, ошибка: \(error)")
            return false
        }
    }
}

extension SWAddress {
    /// Полный адрес местоположения
    static func fullAddress(for placemark: CLPlacemark) -> String? {
        let country = placemark.country
        let countryRegion = placemark.administrativeArea
        let countryRegionInfo = placemark.subAdministrativeArea
        let city = placemark.locality
        let cityDistrict = placemark.subLocality
        let street = placemark.thoroughfare
        let houseNumber = placemark.subThoroughfare
        let fullAddress = [country, countryRegion, countryRegionInfo, city, cityDistrict, street, houseNumber]
            .compactMap { $0 }
            .joined(separator: ", ")
        return fullAddress.isEmpty ? nil : fullAddress
    }

    /// Обновляет старый адрес, если нужно
    ///
    /// - Новый адрес должен отличаться от старого
    /// - Адрес включает все доступные данные, полученные из `placemark`
    /// - Адрес используется при создании новой площадки
    static func updateIfNeeded(_ oldAddress: inout String, placemark: CLPlacemark) {
        if let fullAddress = fullAddress(for: placemark), fullAddress != oldAddress {
            oldAddress = fullAddress
            #if DEBUG
            logger.info("Местоположение пользователя: \(fullAddress)")
            #endif
        }
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
    func countries() throws -> [Country] {
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
    func cities() throws -> [City] {
        try countries().flatMap(\.cities)
    }
}

private extension SWAddress {
    private func city(with id: Int, in countryID: Int) throws -> City? {
        let country = try countries().first(where: { $0.id == String(countryID) })
        return country?.cities.first(where: { $0.id == String(id) })
    }
}

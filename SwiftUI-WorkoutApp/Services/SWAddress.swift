import CoreLocation
import Foundation
import OSLog
import SWModels
import SWUtils

/// Модель для работы с адресами и справочником стран/городов
struct SWAddress {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SWAddress")
    private let storage = SWFileManager(fileName: "CountriesAndCities.json")
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
            logger.error("Не смогли получить название города, \(error.localizedDescription, privacy: .public)")
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
            logger.debug("Успешно сохранили список стран в количестве \(countries.count, privacy: .public) шт.")
            return true
        } catch {
            logger.error("Не смогли сохранить список стран, \(error.localizedDescription, privacy: .public)")
            return false
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

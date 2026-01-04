import Foundation

/// Страны и города для редактирования профиля
///
/// - Note: На сервере нельзя указать только страну без города:
/// поле `country_id` будет проигнорировано при сохранении данных на сервере,
/// если не указать `city_id`
public struct EditProfileLocations {
    /// Все доступные страны
    public var countries: [Country]
    /// Все доступные города
    public var cities: [City]

    public init(countries: [Country]) {
        self.countries = countries
        self.cities = countries.flatMap(\.cities)
    }

    public var isEmpty: Bool {
        countries.isEmpty && cities.isEmpty
    }

    /// Результат выбора страны
    public struct SelectCountryResult {
        public let newCountry: Country?
        public let newCity: City?
        public let newCities: [City]
    }

    /// Результат выбора города
    public struct SelectCityResult {
        public let newCity: City?
        public let countryName: String?
    }

    /// Выбирает страну и возвращает результат
    /// - Parameters:
    ///   - name: Имя выбранной страны
    ///   - city: Текущий выбранный город
    /// - Returns: Результат выбора с новой страной, новым городом и списком городов
    public func selectCountry(name: String, city: City?) -> SelectCountryResult {
        let newCountry = countries.first(where: { $0.name == name })
        var newCity: City?
        var newCities: [City] = cities

        if let newCountry, !newCountry.cities.contains(where: { $0 == city }) {
            newCity = nil
            newCities = newCountry.cities
        } else {
            newCity = city
        }

        return SelectCountryResult(newCountry: newCountry, newCity: newCity, newCities: newCities)
    }

    /// Выбирает город и возвращает результат
    /// - Parameters:
    ///   - name: Имя выбранного города
    ///   - country: Текущая выбранная страна
    /// - Returns: Результат выбора с новым городом и именем страны (если нужно выбрать другую страну)
    public func selectCity(name: String, country: Country?) -> SelectCityResult {
        let newCity = cities.first(where: { $0.name == name })
        var countryName: String?

        if let newCity,
           let countryContainingCity = countries.first(where: { $0.cities.contains(newCity) }),
           country != countryContainingCity {
            countryName = countryContainingCity.name
        }

        return SelectCityResult(newCity: newCity, countryName: countryName)
    }
}

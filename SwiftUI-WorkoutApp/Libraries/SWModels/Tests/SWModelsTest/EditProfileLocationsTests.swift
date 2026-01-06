@testable import SWModels
import Testing

struct EditProfileLocationsTests {
    @Test("Должен возвращать true для пустой локации")
    func isEmpty_true() {
        let locations = makeLocations(countries: [])
        #expect(locations.isEmpty)
    }

    @Test("Должен возвращать false для непустой локации")
    func isEmpty_false() {
        let locations = makeLocations()
        #expect(!locations.isEmpty)
    }

    @Test("Должен выбирать страну с сохранением текущего города")
    func selectCountry_keepsCurrentCity() throws {
        let locations = makeLocations()
        let currentCity = makeCity(id: "1", name: "Москва", lat: "55.75", lon: "37.61")
        let countryName = "Россия"

        let result = locations.selectCountry(name: countryName, city: currentCity)
        let country = try #require(result.newCountry)
        #expect(country.name == countryName)
        #expect(result.newCity == currentCity)
        #expect(!result.newCities.isEmpty)
    }

    @Test("Должен выбирать страну и сбрасывать город, если он не в списке городов новой страны")
    func selectCountry_resetsCity() throws {
        let locations = makeLocations()
        let currentCity = makeCity(id: "999", name: "Неизвестный город", lat: "0.0", lon: "0.0")
        let countryName = "Россия"

        let result = locations.selectCountry(name: countryName, city: currentCity)
        let country = try #require(result.newCountry)
        #expect(country.name == countryName)
        #expect(result.newCity == nil)
        #expect(!result.newCities.isEmpty)
    }

    @Test("Должен выбирать страну с пустым текущим городом")
    func selectCountry_nilCurrentCity() throws {
        let locations = makeLocations()
        let countryName = "Россия"

        let result = locations.selectCountry(name: countryName, city: nil)
        let country = try #require(result.newCountry)
        #expect(country.name == countryName)
        #expect(result.newCity == nil)
        #expect(!result.newCities.isEmpty)
    }

    @Test("Должен возвращать nil при выборе несуществующей страны")
    func selectCountry_notFound() {
        let locations = makeLocations()
        let currentCity = makeCity(id: "1", name: "Москва", lat: "55.75", lon: "37.61")
        let countryName = "Несуществующая страна"

        let result = locations.selectCountry(name: countryName, city: currentCity)

        #expect(result.newCountry == nil)
        #expect(result.newCity == currentCity)
        #expect(!result.newCities.isEmpty)
    }

    @Test("Должен обновлять список городов при выборе страны")
    func selectCountry_updatesCitiesList() {
        let locations = makeLocations()
        let countryName = "Россия"

        let result = locations.selectCountry(name: countryName, city: nil)

        #expect(result.newCities.count == 2)
    }

    @Test("Должен выбирать город из той же страны")
    func selectCity_sameCountry() throws {
        let locations = makeLocations()
        let currentCountry = locations.countries.first(where: { $0.name == "Россия" })
        let cityName = "Москва"

        let result = locations.selectCity(name: cityName, country: currentCountry)
        let city = try #require(result.newCity)
        #expect(city.name == cityName)
        #expect(result.countryName == nil)
    }

    @Test("Должен выбирать город из другой страны")
    func selectCity_differentCountry() throws {
        let locations = makeLocations()
        let currentCountry = locations.countries.first(where: { $0.name == "Россия" })
        let cityName = "Нью-Йорк"

        let result = locations.selectCity(name: cityName, country: currentCountry)
        let city = try #require(result.newCity)
        #expect(city.name == cityName)
        #expect(result.countryName == "США")
    }

    @Test("Должен возвращать nil при выборе несуществующего города")
    func selectCity_notFound() {
        let locations = makeLocations()
        let currentCountry = locations.countries.first(where: { $0.name == "Россия" })
        let cityName = "Несуществующий город"

        let result = locations.selectCity(name: cityName, country: currentCountry)

        #expect(result.newCity == nil)
        #expect(result.countryName == nil)
    }

    @Test("Должен выбирать город без текущей страны")
    func selectCity_nilCountry() throws {
        let locations = makeLocations()
        let cityName = "Москва"

        let result = locations.selectCity(name: cityName, country: nil)
        let city = try #require(result.newCity)
        #expect(city.name == cityName)
        #expect(result.countryName == "Россия")
    }

    @Test("Должен возвращать все города для списка стран", arguments: ["Россия", "США", "Франция"])
    func countriesContainCities(countryName: String) throws {
        let locations = makeLocations()
        let country = try #require(locations.countries.first(where: { $0.name == countryName }))
        #expect(!country.cities.isEmpty)
    }
}

private extension EditProfileLocationsTests {
    func makeLocations(countries: [Country]? = nil) -> EditProfileLocations {
        let defaultCountries = [
            makeCountry(id: "1", name: "Россия", cities: [
                makeCity(id: "1", name: "Москва", lat: "55.75", lon: "37.61"),
                makeCity(id: "2", name: "Санкт-Петербург", lat: "59.93", lon: "30.33")
            ]),
            makeCountry(id: "2", name: "США", cities: [
                makeCity(id: "3", name: "Нью-Йорк", lat: "40.71", lon: "-74.00"),
                makeCity(id: "4", name: "Лос-Анджелес", lat: "34.05", lon: "-118.24")
            ]),
            makeCountry(id: "3", name: "Франция", cities: [
                makeCity(id: "5", name: "Париж", lat: "48.85", lon: "2.35"),
                makeCity(id: "6", name: "Лион", lat: "45.75", lon: "4.85")
            ])
        ]

        return EditProfileLocations(countries: countries ?? defaultCountries)
    }

    func makeCountry(id: String, name: String, cities: [City] = []) -> Country {
        Country(cities: cities, id: id, name: name)
    }

    func makeCity(id: String, name: String, lat: String, lon: String) -> City {
        City(id: id, name: name, lat: lat, lon: lon)
    }
}

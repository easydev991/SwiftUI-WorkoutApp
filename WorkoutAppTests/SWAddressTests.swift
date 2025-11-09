import Foundation
import MapKit
import SWModels
import SWUtils
import Testing
@testable import WorkoutApp

struct SWAddressTests {
    // MARK: - Тесты инициализаторов

    @Test("Должен возвращать nil когда countryId nil")
    func shouldReturnNilWhenCountryIdIsNil() {
        let address = SWAddress(nil, 2)
        #expect(address == nil)
    }

    @Test("Должен возвращать nil когда cityId nil")
    func shouldReturnNilWhenCityIdIsNil() {
        let address = SWAddress(1, nil)
        #expect(address == nil)
    }

    @Test("Должен возвращать nil когда оба ID nil")
    func shouldReturnNilWhenBothIdsAreNil() {
        let address = SWAddress(nil, nil)
        #expect(address == nil)
    }

    @Test("Должен создавать адрес с нулевыми ID для работы со справочником")
    func shouldCreateAddressWithZeroIdsForDirectoryAccess() {
        let address = SWAddress()
        #expect(address.address == "")
    }

    // MARK: - Тесты computed property address

    @Test("Должен возвращать полный адрес когда страна и город найдены")
    func shouldReturnFullAddressWhenCountryAndCityFound() throws {
        let city = makeCity(id: "2", name: "Москва")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.address == "Россия, Москва")
    }

    @Test("Должен возвращать только страну когда город не найден")
    func shouldReturnOnlyCountryWhenCityNotFound() throws {
        let country = try makeCountry(id: "1", name: "Россия", cities: [])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.address == "Россия")
    }

    @Test("Должен возвращать пустую строку когда countryId равен 0")
    func shouldReturnEmptyStringWhenCountryIdIsZero() {
        let storage = makeMockStorage()
        let address = SWAddress(0, 2, storage: storage)
        #expect(address.address == "")
    }

    @Test("Должен возвращать пустую строку когда cityId равен 0")
    func shouldReturnEmptyStringWhenCityIdIsZero() {
        let storage = makeMockStorage()
        let address = SWAddress(1, 0, storage: storage)
        #expect(address.address == "")
    }

    @Test("Должен возвращать пустую строку когда страна не найдена")
    func shouldReturnEmptyStringWhenCountryNotFound() throws {
        let country = try makeCountry(id: "2", name: "Другая страна")
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.address == "")
    }

    @Test("Должен возвращать пустую строку когда storage выбрасывает ошибку")
    func shouldReturnEmptyStringWhenStorageThrowsError() {
        let storage = makeMockStorage(documentExists: true)
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.address == "")
    }

    // MARK: - Тесты computed property coordinate

    @Test("Должен возвращать координаты когда город найден с валидными координатами")
    func shouldReturnCoordinatesWhenCityFoundWithValidCoordinates() throws {
        let city = makeCity(id: "2", name: "Москва", lat: "55.7558", lon: "37.6173")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        let coordinate = try #require(address.coordinate)
        #expect(coordinate.lat == 55.7558)
        #expect(coordinate.lon == 37.6173)
    }

    @Test("Должен возвращать nil когда countryId равен 0")
    func shouldReturnNilWhenCountryIdIsZeroForCoordinate() {
        let storage = makeMockStorage()
        let address = SWAddress(0, 2, storage: storage)
        #expect(address.coordinate == nil)
    }

    @Test("Должен возвращать nil когда cityId равен 0")
    func shouldReturnNilWhenCityIdIsZeroForCoordinate() {
        let storage = makeMockStorage()
        let address = SWAddress(1, 0, storage: storage)
        #expect(address.coordinate == nil)
    }

    @Test("Должен возвращать nil когда город не найден")
    func shouldReturnNilWhenCityNotFoundForCoordinate() throws {
        let country = try makeCountry(id: "1", name: "Россия", cities: [])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.coordinate == nil)
    }

    @Test("Должен возвращать nil когда lat не является числом")
    func shouldReturnNilWhenLatIsNotNumber() throws {
        let city = makeCity(id: "2", name: "Москва", lat: "invalid", lon: "37.6173")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.coordinate == nil)
    }

    @Test("Должен возвращать nil когда lon не является числом")
    func shouldReturnNilWhenLonIsNotNumber() throws {
        let city = makeCity(id: "2", name: "Москва", lat: "55.7558", lon: "invalid")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.coordinate == nil)
    }

    @Test("Должен возвращать nil когда storage выбрасывает ошибку для coordinate")
    func shouldReturnNilWhenStorageThrowsErrorForCoordinate() {
        let storage = makeMockStorage()
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.coordinate == nil)
    }

    // MARK: - Тесты computed property cityName

    @Test("Должен возвращать название города когда город найден")
    func shouldReturnCityNameWhenCityFound() throws {
        let city = makeCity(id: "2", name: "Москва")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        let cityName = try #require(address.cityName)
        #expect(cityName == "Москва")
    }

    @Test("Должен возвращать nil когда город не найден для cityName")
    func shouldReturnNilWhenCityNotFoundForCityName() throws {
        let country = try makeCountry(id: "1", name: "Россия", cities: [])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.cityName == nil)
    }

    @Test("Должен возвращать nil когда storage выбрасывает ошибку для cityName")
    func shouldReturnNilWhenStorageThrowsErrorForCityName() {
        let storage = makeMockStorage()
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        let address = SWAddress(1, 2, storage: storage)
        #expect(address.cityName == nil)
    }

    // MARK: - Тесты метода save

    @Test("Должен сохранять список стран через storage")
    func shouldSaveCountriesThroughStorage() throws {
        let storage = makeMockStorage()
        let address = SWAddress(storage: storage)
        let countries = try [makeCountry(id: "1", name: "Россия")]
        try address.save(countries)
        #expect(storage.saveCallCount == 1)
        let savedData = try #require(storage.savedData as? [Country])
        let firstCountry = try #require(savedData.first)
        #expect(savedData.count == 1)
        #expect(firstCountry.name == "Россия")
    }

    @Test("Должен пробрасывать ошибку когда storage выбрасывает ошибку при save")
    func shouldThrowErrorWhenStorageThrowsErrorOnSave() throws {
        let storage = makeMockStorage()
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        let address = SWAddress(storage: storage)
        let countries = try [makeCountry(id: "1", name: "Россия")]
        #expect(throws: NSError.self) {
            try address.save(countries)
        }
    }

    // MARK: - Тесты метода needUpdate

    @Test("Должен возвращать true когда прошло больше дня")
    func shouldReturnTrueWhenMoreThanDayPassed() {
        let address = SWAddress()
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60)
        #expect(address.needUpdate(twoDaysAgo))
    }

    @Test("Должен возвращать false когда прошло меньше дня")
    func shouldReturnFalseWhenLessThanDayPassed() {
        let address = SWAddress()
        let twelveHoursAgo = Date().addingTimeInterval(-12 * 60 * 60)
        #expect(!address.needUpdate(twelveHoursAgo))
    }

    @Test("Должен возвращать false когда прошло ровно день")
    func shouldReturnFalseWhenExactlyDayPassed() {
        let address = SWAddress()
        let exactlyDayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        #expect(!address.needUpdate(exactlyDayAgo))
    }

    // MARK: - Тесты статического метода countries()

    @Test("Должен возвращать данные из storage когда файл существует")
    func shouldReturnDataFromStorageWhenFileExists() throws {
        let country = try makeCountry(id: "1", name: "Россия")
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let countries = try SWAddress.countries(storage: storage)
        let firstCountry = try #require(countries.first)
        #expect(countries.count == 1)
        #expect(firstCountry.name == "Россия")
    }

    @Test("Должен пробрасывать ошибку когда storage выбрасывает ошибку и файл существует")
    func shouldThrowErrorWhenStorageThrowsErrorAndFileExists() {
        let storage = makeMockStorage(documentExists: true)
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        #expect(throws: NSError.self) {
            try SWAddress.countries(storage: storage)
        }
    }

    // MARK: - Тесты статического метода cities()

    @Test("Должен возвращать все города из всех стран")
    func shouldReturnAllCitiesFromAllCountries() throws {
        let city1 = makeCity(id: "1", name: "Москва")
        let city2 = makeCity(id: "2", name: "Санкт-Петербург")
        let country1 = try makeCountry(id: "1", name: "Россия", cities: [city1])
        let country2 = try makeCountry(id: "2", name: "Беларусь", cities: [city2])
        let storage = makeMockStorage(countries: [country1, country2], documentExists: true)
        let cities = try SWAddress.cities(storage: storage)
        #expect(cities.count == 2)
        #expect(cities.map(\.name).contains("Москва"))
        #expect(cities.map(\.name).contains("Санкт-Петербург"))
    }

    @Test("Должен возвращать пустой массив когда стран нет")
    func shouldReturnEmptyArrayWhenNoCountries() throws {
        let storage = makeMockStorage(countries: [], documentExists: true)
        let cities = try SWAddress.cities(storage: storage)
        #expect(cities.isEmpty)
    }

    @Test("Должен пробрасывать ошибку когда countries() выбрасывает ошибку")
    func shouldThrowErrorWhenCountriesThrowsError() {
        let storage = makeMockStorage(documentExists: true)
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        #expect(throws: NSError.self) {
            try SWAddress.cities(storage: storage)
        }
    }

    // MARK: - Тесты статического метода findCity(with:)

    @Test("Должен находить город по точному названию")
    func shouldFindCityByExactName() throws {
        let city = makeCity(id: "1", name: "Москва")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let foundCity = try SWAddress.findCity(with: "Москва", storage: storage)
        #expect(foundCity.name == "Москва")
    }

    @Test("Должен находить город по названию без учета регистра")
    func shouldFindCityByNameCaseInsensitive() throws {
        let city = makeCity(id: "1", name: "Москва")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let foundCity = try SWAddress.findCity(with: "москва", storage: storage)
        #expect(foundCity.name == "Москва")
    }

    @Test("Должен выбрасывать AddressError.failedToFindCityByName когда город не найден")
    func shouldThrowAddressErrorWhenCityNotFound() throws {
        let country = try makeCountry(id: "1", name: "Россия", cities: [])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        #expect(throws: SWAddress.AddressError.self) {
            try SWAddress.findCity(with: "Неизвестный", storage: storage)
        }
    }

    @Test("Должен пробрасывать ошибку когда cities() выбрасывает ошибку")
    func shouldThrowErrorWhenCitiesThrowsErrorForFindCity() {
        let storage = makeMockStorage(documentExists: true)
        storage.errorToThrow = NSError(domain: "TestError", code: 1)
        #expect(throws: NSError.self) {
            try SWAddress.findCity(with: "Москва", storage: storage)
        }
    }

    // MARK: - Тесты статического метода makeAddress(for:)

    @Test("Должен создавать адрес из всех компонентов placemark")
    func shouldCreateAddressFromAllPlacemarkComponents() throws {
        let placemark = makePlacemark(
            country: "Россия",
            administrativeArea: "Московская область",
            locality: "Москва",
            thoroughfare: "Тверская улица",
            subThoroughfare: "1"
        )
        let address = try #require(SWAddress.makeAddress(for: placemark))
        #expect(address.contains("Россия"))
        #expect(address.contains("Московская область"))
        #expect(address.contains("Москва"))
    }

    @Test("Должен удалять дубликаты компонентов")
    func shouldRemoveDuplicateComponents() throws {
        let placemark = makePlacemark(
            country: "Россия",
            locality: "Россия",
            thoroughfare: "Улица"
        )
        let address = try #require(SWAddress.makeAddress(for: placemark))
        let components = address.components(separatedBy: ", ")
        let uniqueComponents = Set(components)
        #expect(components.count == uniqueComponents.count)
    }

    @Test("Должен сохранять порядок компонентов")
    func shouldPreserveComponentsOrder() throws {
        let placemark = makePlacemark(
            country: "Россия",
            administrativeArea: "Область",
            locality: "Город"
        )
        let address = try #require(SWAddress.makeAddress(for: placemark))
        let components = address.components(separatedBy: ", ")
        #expect(components.first == "Россия")
    }

    @Test("Должен возвращать nil когда все компоненты nil")
    func shouldReturnNilWhenAllComponentsNil() {
        let placemark = makePlacemark()
        #expect(SWAddress.makeAddress(for: placemark) == nil)
    }

    // MARK: - Тесты статического метода makeCityId(with:)

    @Test("Должен возвращать cityId когда город найден")
    func shouldReturnCityIdWhenCityFound() throws {
        let city = makeCity(id: "1", name: "Москва")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        let cityId = try #require(SWAddress.makeCityId(with: "Москва", storage: storage))
        #expect(cityId == 1)
    }

    @Test("Должен возвращать nil когда placemarkLocality nil")
    func shouldReturnNilWhenPlacemarkLocalityNil() {
        let storage = makeMockStorage()
        #expect(SWAddress.makeCityId(with: nil, storage: storage) == nil)
    }

    @Test("Должен возвращать nil когда город не найден")
    func shouldReturnNilWhenCityNotFoundForMakeCityId() throws {
        let country = try makeCountry(id: "1", name: "Россия", cities: [])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        #expect(SWAddress.makeCityId(with: "Неизвестный", storage: storage) == nil)
    }

    @Test("Должен возвращать nil когда city.id не является числом")
    func shouldReturnNilWhenCityIdIsNotNumber() throws {
        let city = makeCity(id: "invalid", name: "Москва")
        let country = try makeCountry(id: "1", name: "Россия", cities: [city])
        let storage = makeMockStorage(countries: [country], documentExists: true)
        #expect(SWAddress.makeCityId(with: "Москва", storage: storage) == nil)
    }

    // MARK: - Тесты AddressError

    @Test("Должен иметь правильное описание ошибки для failedToFindCityByName")
    func shouldHaveCorrectErrorDescriptionForFailedToFindCityByName() throws {
        let error = SWAddress.AddressError.failedToFindCityByName("Москва")
        let description = try #require(error.errorDescription)
        #expect(description.contains("Москва"))
    }
}

// MARK: - Вспомогательные функции

private extension SWAddressTests {
    func makeCountry(id: String, name: String, cities: [City] = []) throws -> Country {
        let citiesData = try JSONEncoder().encode(cities)
        let citiesJSON = try #require(String(data: citiesData, encoding: .utf8))
        let json = """
        {
            "id": "\(id)",
            "name": "\(name)",
            "cities": \(citiesJSON)
        }
        """
        let data = try #require(json.data(using: .utf8))
        return try JSONDecoder().decode(Country.self, from: data)
    }

    func makeCity(id: String, name: String, lat: String = "0.0", lon: String = "0.0") -> City {
        City(id: id, name: name, lat: lat, lon: lon)
    }

    func makeMockStorage(countries: [Country]? = nil, documentExists: Bool = false) -> MockSWFileManagerImp {
        let storage = MockSWFileManagerImp()
        storage.documentExists = documentExists
        if let countries {
            storage.dataToReturn = countries
        }
        return storage
    }

    func makePlacemark(
        country: String? = nil,
        administrativeArea: String? = nil,
        subAdministrativeArea: String? = nil,
        locality: String? = nil,
        subLocality: String? = nil,
        thoroughfare: String? = nil,
        subThoroughfare: String? = nil
    ) -> CLPlacemark {
        var addressDict: [String: Any] = [:]
        if let country {
            addressDict["Country"] = country
        }
        if let administrativeArea {
            addressDict["State"] = administrativeArea
        }
        if let subAdministrativeArea {
            addressDict["SubAdministrativeArea"] = subAdministrativeArea
        }
        if let locality {
            addressDict["City"] = locality
        }
        if let subLocality {
            addressDict["SubLocality"] = subLocality
        }
        if let thoroughfare {
            addressDict["Street"] = thoroughfare
        }
        if let subThoroughfare {
            addressDict["SubThoroughfare"] = subThoroughfare
        }
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict.isEmpty ? nil : addressDict)
        return placemark
    }
}

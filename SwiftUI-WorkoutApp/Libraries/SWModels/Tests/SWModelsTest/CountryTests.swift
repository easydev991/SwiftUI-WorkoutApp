import Foundation
@testable import SWModels
import Testing

struct CountryTests {
    @Test("Должен возвращать подсказку для страны с id = 0")
    func hintForEmptyCountry() {
        let country = Country(cities: [], id: "0", name: "")
        let hint = country.hint

        #expect(hint != nil)
    }

    @Test("Должен возвращать подсказку для страны с id = 0 с городами")
    func hintForEmptyCountryWithCities() {
        let cities = [City(id: "1", name: "Москва", lat: "55.753215", lon: "37.622504")]
        let country = Country(cities: cities, id: "0", name: "Страна")
        let hint = country.hint

        #expect(hint != nil)
    }

    @Test("Должен возвращать nil для страны с валидным id")
    func hintForValidCountry() {
        let country = Country(cities: [], id: "17", name: "Россия")
        let hint = country.hint

        #expect(hint == nil)
    }

    @Test("Должен возвращать nil для страны с id отличным от 0")
    func hintForCountryWithDifferentId() {
        let country = Country(cities: [], id: "5", name: "Тестовая страна")
        let hint = country.hint

        #expect(hint == nil)
    }

    @Test("Должен возвращать nil для страны по умолчанию")
    func hintForDefaultCountry() {
        let country = Country.defaultCountry
        let hint = country.hint

        #expect(hint == nil)
    }
}

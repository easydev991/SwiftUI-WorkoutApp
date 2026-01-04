import Foundation
@testable import SWModels
import Testing

struct CityTests {
    @Test("Должен возвращать подсказку для города с id = 0")
    func hintForEmptyCity() {
        let city = City(id: "0")
        let hint = city.hint

        #expect(hint != nil)
    }

    @Test("Должен возвращать подсказку для города с id = 0 с пустым именем")
    func hintForEmptyCityWithEmptyName() {
        let city = City(id: "0", name: "", lat: "55.753215", lon: "37.622504")
        let hint = city.hint

        #expect(hint != nil)
    }

    @Test("Должен возвращать nil для города с валидным id")
    func hintForValidCity() {
        let city = City(id: "1", name: "Москва", lat: "55.753215", lon: "37.622504")
        let hint = city.hint

        #expect(hint == nil)
    }

    @Test("Должен возвращать nil для города с id отличным от 0")
    func hintForCityWithDifferentId() {
        let city = City(id: "5")
        let hint = city.hint

        #expect(hint == nil)
    }

    @Test("Должен возвращать nil для города по умолчанию")
    func hintForDefaultCity() {
        let city = City.defaultCity
        let hint = city.hint

        #expect(hint == nil)
    }
}

import CoreLocation
@testable import SWModels
import Testing

struct NewParkMapModelTests {
    private typealias SUT = NewParkMapModel

    @Test("Проверка корректной инициализации модели")
    func initialization() {
        let address = "Красная площадь, Москва"
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let cityId = 1
        let model = SUT(address: address, coordinate: coordinate, cityId: cityId)
        #expect(model.address == address)
        #expect(model.latitude == coordinate.latitude)
        #expect(model.longitude == coordinate.longitude)
        #expect(model.cityId == cityId)
    }

    @Test("Проверка свойства coordinate")
    func coordinateComputedProperty() {
        let latitude = 40.7128
        let longitude = -74.0060
        let sut = SUT(
            address: "New York",
            coordinate: .init(latitude: latitude, longitude: longitude),
            cityId: 2
        )
        let coordinate = sut.coordinate
        #expect(coordinate.latitude == latitude)
        #expect(coordinate.longitude == longitude)
    }

    @Test("Проверка свойства isEmpty для непустой модели")
    func isNotEmpty() {
        let sut = SUT(
            address: "Парк Горького",
            coordinate: .init(latitude: 55.7297, longitude: 37.6014),
            cityId: 1
        )
        #expect(!sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с пустым адресом")
    func isEmptyWithEmptyAddress() {
        let sut = SUT(
            address: "",
            coordinate: .init(latitude: 55.7297, longitude: 37.6014),
            cityId: 1
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевой широтой")
    func isEmptyWithZeroLatitude() {
        let sut = SUT(
            address: "Парк Горького",
            coordinate: .init(latitude: 0, longitude: 37.6014),
            cityId: 1
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевой долготой")
    func isEmptyWithZeroLongitude() {
        let sut = SUT(
            address: "Парк Горького",
            coordinate: .init(latitude: 55.7297, longitude: 0),
            cityId: 1
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка статического свойства empty")
    func staticEmptyProperty() {
        let sut = SUT.empty
        #expect(sut.address.isEmpty)
        #expect(sut.latitude == 0)
        #expect(sut.longitude == 0)
        #expect(sut.cityId == 0)
        #expect(sut.isEmpty)
    }
}

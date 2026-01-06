import CoreLocation
@testable import SWModels
import Testing

struct NewParkMapModelTests {
    private typealias SUT = NewParkMapModel

    @Test("Проверка корректной инициализации модели")
    func initialization() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let lastLocationRequestDate = Date()
        let model = SUT(coordinate: coordinate, lastLocationRequestDate: lastLocationRequestDate)
        #expect(model.latitude == coordinate.latitude)
        #expect(model.longitude == coordinate.longitude)
        #expect(model.lastLocationRequestDate == lastLocationRequestDate)
        #expect(!model.isEmpty)
    }

    @Test("Проверка свойства coordinate")
    func coordinateComputedProperty() {
        let latitude = 40.7128
        let longitude = -74.0060
        let sut = SUT(
            coordinate: .init(latitude: latitude, longitude: longitude)
        )
        let coordinate = sut.coordinate
        #expect(coordinate.latitude == latitude)
        #expect(coordinate.longitude == longitude)
    }

    @Test("Проверка свойства isEmpty для непустой модели")
    func isNotEmpty() {
        let sut = SUT(
            coordinate: .init(latitude: 55.7297, longitude: 37.6014)
        )
        #expect(!sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевой широтой")
    func isEmptyWithZeroLatitude() {
        let sut = SUT(
            coordinate: .init(latitude: 0, longitude: 37.6014)
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевой долготой")
    func isEmptyWithZeroLongitude() {
        let sut = SUT(
            coordinate: .init(latitude: 55.7297, longitude: 0)
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка статического свойства empty")
    func staticEmptyProperty() {
        let sut = SUT.empty
        #expect(sut.latitude == 0)
        #expect(sut.longitude == 0)
        #expect(sut.lastLocationRequestDate == nil)
        #expect(sut.isEmpty)
    }

    @Test("Проверка инициализатора с обновлением координат")
    func initializationWithUpdatedCoordinates() {
        let originalCoordinate = CLLocationCoordinate2D(latitude: 55.7297, longitude: 37.6014)
        let originalDate = Date()
        let oldModel = SUT(
            coordinate: originalCoordinate,
            lastLocationRequestDate: originalDate
        )
        let newLatitude = 59.9311
        let newLongitude = 30.3609
        let newModel = SUT(
            oldModel: oldModel,
            newLatitude: newLatitude,
            newLongitude: newLongitude
        )
        #expect(newModel.latitude == newLatitude)
        #expect(newModel.longitude == newLongitude)
        #expect(newModel.lastLocationRequestDate == originalDate)
        #expect(!newModel.isEmpty)
    }

    @Test("Проверка сохранения lastLocationRequestDate при обновлении координат")
    func preservesDateWhenUpdatingCoordinates() {
        let originalDate = Date()
        let originalModel = SUT(
            coordinate: .init(latitude: 40.7829, longitude: -73.9654),
            lastLocationRequestDate: originalDate
        )
        let updatedModel = SUT(
            oldModel: originalModel,
            newLatitude: 51.5074,
            newLongitude: -0.1278
        )
        #expect(updatedModel.lastLocationRequestDate == originalDate)
        #expect(updatedModel.latitude != originalModel.latitude)
        #expect(updatedModel.longitude != originalModel.longitude)
    }

    @Test("Проверка coordinate свойства после обновления координат")
    func coordinatePropertyAfterUpdate() {
        let oldModel = SUT(
            coordinate: .init(latitude: 55.7942, longitude: 37.6736)
        )
        let newLatitude = 55.8431
        let newLongitude = 37.6156
        let updatedModel = SUT(
            oldModel: oldModel,
            newLatitude: newLatitude,
            newLongitude: newLongitude
        )
        let coordinate = updatedModel.coordinate
        #expect(coordinate.latitude == newLatitude)
        #expect(coordinate.longitude == newLongitude)
    }

    @Test("Проверка isEmpty после обновления на нулевые координаты")
    func isEmptyAfterUpdatingToZeroCoordinates() {
        let oldModel = SUT(
            coordinate: .init(latitude: 55.7942, longitude: 37.8064)
        )
        let updatedModel = SUT(
            oldModel: oldModel,
            newLatitude: 0,
            newLongitude: 0
        )
        #expect(updatedModel.isEmpty)
    }

    @Test("Проверка isEmpty после обновления одной координаты на ноль")
    func isEmptyAfterUpdatingOneCoordinateToZero() {
        let oldModel = SUT(
            coordinate: .init(latitude: 55.7155, longitude: 37.5393)
        )
        let modelWithZeroLatitude = SUT(
            oldModel: oldModel,
            newLatitude: 0,
            newLongitude: 37.5393
        )
        let modelWithZeroLongitude = SUT(
            oldModel: oldModel,
            newLatitude: 55.7155,
            newLongitude: 0
        )
        #expect(modelWithZeroLatitude.isEmpty)
        #expect(modelWithZeroLongitude.isEmpty)
    }

    @Test("Проверка обновления координат пустой модели")
    func updatingEmptyModel() {
        let emptyModel = SUT.empty

        let updatedModel = SUT(
            oldModel: emptyModel,
            newLatitude: 55.7558,
            newLongitude: 37.6176
        )

        #expect(updatedModel.latitude == 55.7558)
        #expect(updatedModel.longitude == 37.6176)
        #expect(updatedModel.lastLocationRequestDate == nil)
        #expect(!updatedModel.isEmpty)
    }

    @Test("Проверка метода updatingLastLocationRequestDate")
    func updatingLastLocationRequestDate() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208)
        )
        #expect(originalModel.lastLocationRequestDate == nil)

        let newDate = Date()
        let updatedModel = originalModel.updatingLastLocationRequestDate(newDate)

        #expect(updatedModel.coordinate.latitude == originalModel.coordinate.latitude)
        #expect(updatedModel.coordinate.longitude == originalModel.coordinate.longitude)
        #expect(updatedModel.lastLocationRequestDate == newDate)
    }

    @Test("Проверка isEmpty с нулевыми координатами")
    func isEmptyWithZeroCoordinates() {
        let modelWithZeroLatitude = SUT(
            coordinate: .init(latitude: 0, longitude: 37.6208)
        )
        let modelWithZeroLongitude = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 0)
        )
        let emptyModel = SUT.empty
        #expect(modelWithZeroLatitude.isEmpty)
        #expect(modelWithZeroLongitude.isEmpty)
        #expect(emptyModel.isEmpty)
    }

    @Test("Проверка свойства shouldRequestLocation без даты запроса")
    func shouldRequestLocationWithoutDate() {
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208)
        )
        #expect(model.shouldRequestLocation)
    }

    @Test("Проверка свойства shouldRequestLocation с недавней датой запроса")
    func shouldRequestLocationWithRecentDate() {
        let recentDate = Date().addingTimeInterval(-5) // 5 секунд назад
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            lastLocationRequestDate: recentDate
        )
        #expect(!model.shouldRequestLocation)
    }

    @Test("Проверка свойства shouldRequestLocation со старой датой запроса")
    func shouldRequestLocationWithOldDate() {
        let oldDate = Date().addingTimeInterval(-15) // 15 секунд назад
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            lastLocationRequestDate: oldDate
        )
        #expect(model.shouldRequestLocation)
    }

    @Test("Проверка shouldRequestLocation с невалидными координатами")
    func shouldRequestLocationWithInvalidCoordinates() {
        let modelWithZeroLatitude = SUT(
            coordinate: .init(latitude: 0, longitude: 37.6208),
            lastLocationRequestDate: Date().addingTimeInterval(-15)
        )
        let modelWithZeroLongitude = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 0),
            lastLocationRequestDate: Date().addingTimeInterval(-15)
        )
        let modelWithZeroCoordinates = SUT(
            coordinate: .init(latitude: 0, longitude: 0),
            lastLocationRequestDate: Date().addingTimeInterval(-15)
        )
        #expect(modelWithZeroLatitude.shouldRequestLocation)
        #expect(modelWithZeroLongitude.shouldRequestLocation)
        #expect(modelWithZeroCoordinates.shouldRequestLocation)
    }

    @Test("Проверка метода withoutAddress - обнуляет адрес но сохраняет остальные данные")
    func withoutAddressResetsAddressButPreservesOtherData() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let date = Date()
        let originalModel = SUT(
            coordinate: coordinate,
            lastLocationRequestDate: date,
            address: "Москва, Красная площадь",
            cityId: 1
        )
        let modelWithoutAddress = originalModel.withoutAddress()
        #expect(modelWithoutAddress.address.isEmpty)
        #expect(modelWithoutAddress.coordinate.latitude == coordinate.latitude)
        #expect(modelWithoutAddress.coordinate.longitude == coordinate.longitude)
        #expect(modelWithoutAddress.lastLocationRequestDate == date)
        #expect(modelWithoutAddress.cityId == 1)
    }

    @Test("Проверка метода withoutAddress с пустым адресом")
    func withoutAddressWithEmptyAddress() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let originalModel = SUT(
            coordinate: coordinate,
            address: "",
            cityId: 5
        )
        let modelWithoutAddress = originalModel.withoutAddress()
        #expect(modelWithoutAddress.address.isEmpty)
        #expect(modelWithoutAddress.coordinate.latitude == coordinate.latitude)
        #expect(modelWithoutAddress.coordinate.longitude == coordinate.longitude)
        #expect(modelWithoutAddress.cityId == 5)
        #expect(modelWithoutAddress.lastLocationRequestDate == nil)
    }

    @Test("Проверка shouldPerformGeocode после withoutAddress")
    func shouldPerformGeocodeAfterWithoutAddress() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            address: "Москва, Красная площадь",
            cityId: 1
        )
        #expect(!originalModel.shouldPerformGeocode, "Изначально геокодирование не требуется")
        let modelWithoutAddress = originalModel.withoutAddress()
        #expect(modelWithoutAddress.shouldPerformGeocode, "После обнуления адреса геокодирование требуется")
    }

    @Test("Проверка withoutAddress не влияет на isEmpty")
    func withoutAddressDoesNotAffectIsEmpty() {
        let nonEmptyModel = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            address: "Тестовый адрес",
            cityId: 1
        )
        let emptyModel = SUT(
            coordinate: .init(latitude: 0, longitude: 0),
            address: "Тестовый адрес",
            cityId: 1
        )
        #expect(!nonEmptyModel.isEmpty)
        #expect(!nonEmptyModel.withoutAddress().isEmpty)
        #expect(emptyModel.isEmpty)
        #expect(emptyModel.withoutAddress().isEmpty)
    }

    @Test("Проверка shouldPerformGeocode с nil cityId")
    func shouldPerformGeocodeWithNilCityId() {
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            address: "Москва, Красная площадь",
            cityId: nil
        )
        #expect(model.shouldPerformGeocode)
    }

    @Test("Проверка shouldPerformGeocode с cityId равным 0")
    func shouldPerformGeocodeWithZeroCityId() {
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            address: "Москва, Красная площадь",
            cityId: 0
        )
        #expect(model.shouldPerformGeocode)
    }

    @Test("Проверка shouldPerformGeocode с валидным cityId и адресом")
    func shouldPerformGeocodeWithValidCityIdAndAddress() {
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            address: "Москва, Красная площадь",
            cityId: 1
        )
        #expect(!model.shouldPerformGeocode)
    }

    @Test("Проверка shouldPerformGeocode с пустым адресом и валидным cityId")
    func shouldPerformGeocodeWithEmptyAddressAndValidCityId() {
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            address: "",
            cityId: 1
        )
        #expect(model.shouldPerformGeocode)
    }

    @Test("Проверка метода withGeocodingData")
    func withGeocodingData() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let originalModel = SUT(coordinate: coordinate)
        #expect(originalModel.cityId == nil)
        #expect(originalModel.address.isEmpty)

        let updatedModel = originalModel.withGeocodingData(address: "Москва, Красная площадь", cityId: 1)
        #expect(updatedModel.address == "Москва, Красная площадь")
        #expect(updatedModel.cityId == 1)
        #expect(updatedModel.coordinate.latitude == coordinate.latitude)
        #expect(updatedModel.coordinate.longitude == coordinate.longitude)
    }

    @Test("Проверка сохранения cityId при обновлении координат")
    func preservesCityIdWhenUpdatingCoordinates() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7297, longitude: 37.6014),
            cityId: 5
        )
        let updatedModel = SUT(
            oldModel: originalModel,
            newLatitude: 59.9311,
            newLongitude: 30.3609
        )
        #expect(updatedModel.cityId == 5)
        #expect(updatedModel.latitude == 59.9311)
        #expect(updatedModel.longitude == 30.3609)
    }

    @Test("Проверка сохранения nil cityId при обновлении координат")
    func preservesNilCityIdWhenUpdatingCoordinates() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7297, longitude: 37.6014),
            cityId: nil
        )
        let updatedModel = SUT(
            oldModel: originalModel,
            newLatitude: 59.9311,
            newLongitude: 30.3609
        )
        #expect(updatedModel.cityId == nil)
        #expect(updatedModel.latitude == 59.9311)
        #expect(updatedModel.longitude == 30.3609)
    }

    @Test("Проверка сохранения cityId в updatingLastLocationRequestDate")
    func preservesCityIdInUpdatingLastLocationRequestDate() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: 3
        )
        let newDate = Date()
        let updatedModel = originalModel.updatingLastLocationRequestDate(newDate)
        #expect(updatedModel.cityId == 3)
        #expect(updatedModel.lastLocationRequestDate == newDate)
    }

    @Test("Проверка сохранения nil cityId в updatingLastLocationRequestDate")
    func preservesNilCityIdInUpdatingLastLocationRequestDate() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: nil
        )
        let newDate = Date()
        let updatedModel = originalModel.updatingLastLocationRequestDate(newDate)
        #expect(updatedModel.cityId == nil)
        #expect(updatedModel.lastLocationRequestDate == newDate)
    }

    @Test("Проверка сохранения cityId в withoutAddress")
    func preservesCityIdInWithoutAddress() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let originalModel = SUT(
            coordinate: coordinate,
            address: "Москва, Красная площадь",
            cityId: 7
        )
        let modelWithoutAddress = originalModel.withoutAddress()
        #expect(modelWithoutAddress.cityId == 7)
        #expect(modelWithoutAddress.address.isEmpty)
    }

    @Test("Проверка сохранения nil cityId в withoutAddress")
    func preservesNilCityIdInWithoutAddress() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let originalModel = SUT(
            coordinate: coordinate,
            address: "Москва, Красная площадь",
            cityId: nil
        )
        let modelWithoutAddress = originalModel.withoutAddress()
        #expect(modelWithoutAddress.cityId == nil)
        #expect(modelWithoutAddress.address.isEmpty)
    }

    @Test("Проверка инициализации с опциональным cityId")
    func initializationWithOptionalCityId() {
        let modelWithCityId = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: 10
        )
        let modelWithoutCityId = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: nil
        )
        let modelWithDefaultCityId = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208)
        )
        #expect(modelWithCityId.cityId == 10)
        #expect(modelWithoutCityId.cityId == nil)
        #expect(modelWithDefaultCityId.cityId == nil)
    }
}

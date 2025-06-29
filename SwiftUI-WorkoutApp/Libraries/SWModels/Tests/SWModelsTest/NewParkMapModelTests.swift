import CoreLocation
@testable import SWModels
import Testing

struct NewParkMapModelTests {
    private typealias SUT = NewParkMapModel

    @Test("Проверка корректной инициализации модели")
    func initialization() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7539, longitude: 37.6208)
        let cityId = 1
        let lastLocationRequestDate = Date()
        let model = SUT(coordinate: coordinate, cityId: cityId, lastLocationRequestDate: lastLocationRequestDate)
        #expect(model.latitude == coordinate.latitude)
        #expect(model.longitude == coordinate.longitude)
        #expect(model.cityId == cityId)
        #expect(model.lastLocationRequestDate == lastLocationRequestDate)
        #expect(!model.isEmpty)
    }

    @Test("Проверка свойства coordinate")
    func coordinateComputedProperty() {
        let latitude = 40.7128
        let longitude = -74.0060
        let sut = SUT(
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
            coordinate: .init(latitude: 55.7297, longitude: 37.6014),
            cityId: 1
        )
        #expect(!sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевой широтой")
    func isEmptyWithZeroLatitude() {
        let sut = SUT(
            coordinate: .init(latitude: 0, longitude: 37.6014),
            cityId: 1
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевой долготой")
    func isEmptyWithZeroLongitude() {
        let sut = SUT(
            coordinate: .init(latitude: 55.7297, longitude: 0),
            cityId: 1
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка свойства isEmpty для модели с нулевым городом")
    func isEmptyWithZeroCityId() {
        let sut = SUT(
            coordinate: .init(latitude: 55.7297, longitude: 37.6014),
            cityId: 0
        )
        #expect(sut.isEmpty)
    }

    @Test("Проверка статического свойства empty")
    func staticEmptyProperty() {
        let sut = SUT.empty
        #expect(sut.latitude == 0)
        #expect(sut.longitude == 0)
        #expect(sut.cityId == 0)
        #expect(sut.lastLocationRequestDate == nil)
        #expect(sut.isEmpty)
    }

    @Test("Проверка инициализатора с обновлением координат")
    func initializationWithUpdatedCoordinates() {
        let originalCoordinate = CLLocationCoordinate2D(latitude: 55.7297, longitude: 37.6014)
        let originalCityId = 1
        let originalDate = Date()
        let oldModel = SUT(
            coordinate: originalCoordinate,
            cityId: originalCityId,
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
        #expect(newModel.cityId == originalCityId)
        #expect(newModel.lastLocationRequestDate == originalDate)
        #expect(!newModel.isEmpty)
    }

    @Test("Проверка сохранения cityId и lastLocationRequestDate при обновлении координат")
    func preservesCityIdAndDateWhenUpdatingCoordinates() {
        let originalDate = Date()
        let originalModel = SUT(
            coordinate: .init(latitude: 40.7829, longitude: -73.9654),
            cityId: 5,
            lastLocationRequestDate: originalDate
        )
        let updatedModel = SUT(
            oldModel: originalModel,
            newLatitude: 51.5074,
            newLongitude: -0.1278
        )
        #expect(updatedModel.cityId == originalModel.cityId)
        #expect(updatedModel.lastLocationRequestDate == originalDate)
        #expect(updatedModel.latitude != originalModel.latitude)
        #expect(updatedModel.longitude != originalModel.longitude)
    }

    @Test("Проверка coordinate свойства после обновления координат")
    func coordinatePropertyAfterUpdate() {
        let oldModel = SUT(
            coordinate: .init(latitude: 55.7942, longitude: 37.6736),
            cityId: 1
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
            coordinate: .init(latitude: 55.7942, longitude: 37.8064),
            cityId: 1
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
            coordinate: .init(latitude: 55.7155, longitude: 37.5393),
            cityId: 1
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
        #expect(updatedModel.cityId == 0)
        #expect(updatedModel.lastLocationRequestDate == nil)
        #expect(updatedModel.isEmpty)
    }

    @Test("Проверка метода updatingLastLocationRequestDate")
    func updatingLastLocationRequestDate() {
        let originalModel = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: 1
        )
        #expect(originalModel.lastLocationRequestDate == nil)

        let newDate = Date()
        let updatedModel = originalModel.updatingLastLocationRequestDate(newDate)

        #expect(updatedModel.coordinate.latitude == originalModel.coordinate.latitude)
        #expect(updatedModel.coordinate.longitude == originalModel.coordinate.longitude)
        #expect(updatedModel.cityId == originalModel.cityId)
        #expect(updatedModel.lastLocationRequestDate == newDate)
    }

    @Test("Проверка isEmpty с нулевыми координатами")
    func isEmptyWithZeroCoordinates() {
        let modelWithZeroLatitude = SUT(
            coordinate: .init(latitude: 0, longitude: 37.6208),
            cityId: 1
        )
        let modelWithZeroLongitude = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 0),
            cityId: 1
        )
        let emptyModel = SUT.empty
        #expect(modelWithZeroLatitude.isEmpty)
        #expect(modelWithZeroLongitude.isEmpty)
        #expect(emptyModel.isEmpty)
    }

    @Test("Проверка свойства shouldRequestLocation без даты запроса")
    func shouldRequestLocationWithoutDate() {
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: 1
        )
        #expect(model.shouldRequestLocation)
    }

    @Test("Проверка свойства shouldRequestLocation с недавней датой запроса")
    func shouldRequestLocationWithRecentDate() {
        let recentDate = Date().addingTimeInterval(-5) // 5 секунд назад
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: 1,
            lastLocationRequestDate: recentDate
        )
        #expect(!model.shouldRequestLocation)
    }

    @Test("Проверка свойства shouldRequestLocation со старой датой запроса")
    func shouldRequestLocationWithOldDate() {
        let oldDate = Date().addingTimeInterval(-15) // 15 секунд назад
        let model = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 37.6208),
            cityId: 1,
            lastLocationRequestDate: oldDate
        )
        #expect(model.shouldRequestLocation)
    }

    @Test("Проверка shouldRequestLocation с невалидными координатами")
    func shouldRequestLocationWithInvalidCoordinates() {
        let modelWithZeroLatitude = SUT(
            coordinate: .init(latitude: 0, longitude: 37.6208),
            cityId: 1,
            lastLocationRequestDate: Date().addingTimeInterval(-15)
        )
        let modelWithZeroLongitude = SUT(
            coordinate: .init(latitude: 55.7539, longitude: 0),
            cityId: 1,
            lastLocationRequestDate: Date().addingTimeInterval(-15)
        )
        let modelWithZeroCoordinates = SUT(
            coordinate: .init(latitude: 0, longitude: 0),
            cityId: 1,
            lastLocationRequestDate: Date().addingTimeInterval(-15)
        )
        #expect(modelWithZeroLatitude.shouldRequestLocation)
        #expect(modelWithZeroLongitude.shouldRequestLocation)
        #expect(modelWithZeroCoordinates.shouldRequestLocation)
    }
}

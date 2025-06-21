import CoreLocation
import Foundation

public struct NewParkMapModel: Sendable, Equatable {
    public var address: String
    public var latitude: Double
    public var longitude: Double
    public var cityId: Int

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    /// Пустая ли модель
    public var isEmpty: Bool {
        address.isEmpty || latitude == 0 || longitude == 0 || cityId == 0
    }

    /// Инициализатор
    /// - Parameters:
    ///   - address: Точный адрес местонахождения пользователя
    ///   - coordinate: Координаты местонахождения пользователя
    ///   - cityId: Идентификатор города местонахождения пользователя
    public init(address: String, coordinate: CLLocationCoordinate2D, cityId: Int) {
        self.address = address
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.cityId = cityId
    }

    /// Инициализатор для обновления координат
    ///
    /// Копирует из старой модели адрес и идентификатор города,
    /// но сохраняет обновленные координаты
    /// - Parameters:
    ///   - oldModel: Старая модель
    ///   - newLatitude: Новая широта
    ///   - newLongitude: Новая долгота
    public init(oldModel: Self, newLatitude: Double, newLongitude: Double) {
        self.init(
            address: oldModel.address,
            coordinate: .init(latitude: newLatitude, longitude: newLongitude),
            cityId: oldModel.cityId
        )
    }

    public static let empty = Self(
        address: "",
        coordinate: .init(latitude: 0, longitude: 0),
        cityId: 0
    )
}

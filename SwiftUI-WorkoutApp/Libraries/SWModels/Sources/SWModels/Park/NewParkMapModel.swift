import CoreLocation
import Foundation

public struct NewParkMapModel: Sendable, Equatable {
    public var latitude: Double
    public var longitude: Double
    public var cityId: Int
    public var lastLocationRequestDate: Date?

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    /// Пустая ли модель
    public var isEmpty: Bool {
        latitude == 0 || longitude == 0 || cityId == 0
    }

    /// Нужно ли запрашивать новую локацию
    public var shouldRequestLocation: Bool {
        let hasValidCoordinates = latitude != 0 && longitude != 0
        let shouldRequest: Bool = if let lastDate = lastLocationRequestDate {
            Date().timeIntervalSince(lastDate) > 10
        } else {
            true
        }
        return !hasValidCoordinates || shouldRequest
    }

    /// Инициализатор
    /// - Parameters:
    ///   - coordinate: Координаты местонахождения пользователя
    ///   - cityId: Идентификатор города местонахождения пользователя
    ///   - lastLocationRequestDate: Дата последнего запроса локации
    public init(coordinate: CLLocationCoordinate2D, cityId: Int, lastLocationRequestDate: Date? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.cityId = cityId
        self.lastLocationRequestDate = lastLocationRequestDate
    }

    /// Инициализатор для обновления координат
    ///
    /// Копирует из старой модели идентификатор города и дату запроса,
    /// но сохраняет обновленные координаты
    /// - Parameters:
    ///   - oldModel: Старая модель
    ///   - newLatitude: Новая широта
    ///   - newLongitude: Новая долгота
    public init(oldModel: Self, newLatitude: Double, newLongitude: Double) {
        self.init(
            coordinate: .init(latitude: newLatitude, longitude: newLongitude),
            cityId: oldModel.cityId,
            lastLocationRequestDate: oldModel.lastLocationRequestDate
        )
    }

    /// Обновляет дату последнего запроса локации
    /// - Parameter date: Новая дата запроса
    /// - Returns: Обновленная модель
    public func updatingLastLocationRequestDate(_ date: Date) -> Self {
        Self(
            coordinate: coordinate,
            cityId: cityId,
            lastLocationRequestDate: date
        )
    }

    public static let empty = Self(
        coordinate: .init(latitude: 0, longitude: 0),
        cityId: 0,
        lastLocationRequestDate: nil
    )
}

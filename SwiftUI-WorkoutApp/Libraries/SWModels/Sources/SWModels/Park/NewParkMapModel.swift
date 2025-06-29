import CoreLocation
import Foundation

public struct NewParkMapModel: Sendable, Equatable {
    public var latitude: Double
    public var longitude: Double
    public var lastLocationRequestDate: Date?

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    /// Пустая ли модель
    public var isEmpty: Bool {
        latitude == 0 || longitude == 0
    }

    /// Нужно ли запрашивать новую локацию
    public var shouldRequestLocation: Bool {
        let shouldRequest: Bool = if let lastDate = lastLocationRequestDate {
            Date().timeIntervalSince(lastDate) > 10
        } else {
            true
        }
        return isEmpty || shouldRequest
    }

    /// Инициализатор
    /// - Parameters:
    ///   - coordinate: Координаты местонахождения пользователя
    ///   - lastLocationRequestDate: Дата последнего запроса локации
    public init(coordinate: CLLocationCoordinate2D, lastLocationRequestDate: Date? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.lastLocationRequestDate = lastLocationRequestDate
    }

    /// Инициализатор для обновления координат
    ///
    /// Копирует из старой модели дату запроса,
    /// но сохраняет обновленные координаты
    /// - Parameters:
    ///   - oldModel: Старая модель
    ///   - newLatitude: Новая широта
    ///   - newLongitude: Новая долгота
    public init(oldModel: Self, newLatitude: Double, newLongitude: Double) {
        self.init(
            coordinate: .init(latitude: newLatitude, longitude: newLongitude),
            lastLocationRequestDate: oldModel.lastLocationRequestDate
        )
    }

    /// Обновляет дату последнего запроса локации
    /// - Parameter date: Новая дата запроса
    /// - Returns: Обновленная модель
    public func updatingLastLocationRequestDate(_ date: Date) -> Self {
        Self(
            coordinate: coordinate,
            lastLocationRequestDate: date
        )
    }

    public static let empty = Self(
        coordinate: .init(latitude: 0, longitude: 0),
        lastLocationRequestDate: nil
    )
}

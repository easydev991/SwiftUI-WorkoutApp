import CoreLocation
import Foundation

public struct NewParkMapModel: Sendable, Equatable {
    public var latitude: Double
    public var longitude: Double
    public var lastLocationRequestDate: Date?
    /// Адрес площадки, полученный при помощи геокодирования
    public var address: String
    /// Идентификатор города, полученные при помощи геокодирования
    public var cityId: Int

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

    /// Нужно ли выполнять геокодирование
    public var shouldPerformGeocode: Bool {
        address.isEmpty || cityId == 0
    }

    /// Инициализатор
    /// - Parameters:
    ///   - coordinate: Координаты местонахождения пользователя
    ///   - lastLocationRequestDate: Дата последнего запроса локации
    ///   - address: Адрес площадки
    ///   - cityId: Идентификатор города
    public init(
        coordinate: CLLocationCoordinate2D,
        lastLocationRequestDate: Date? = nil,
        address: String = "",
        cityId: Int = 0
    ) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.lastLocationRequestDate = lastLocationRequestDate
        self.address = address
        self.cityId = cityId
    }

    /// Инициализатор для обновления координат
    ///
    /// Копирует из старой модели дату запроса, адрес и cityId,
    /// но сохраняет обновленные координаты
    /// - Parameters:
    ///   - oldModel: Старая модель
    ///   - newLatitude: Новая широта
    ///   - newLongitude: Новая долгота
    public init(oldModel: Self, newLatitude: Double, newLongitude: Double) {
        self.init(
            coordinate: .init(latitude: newLatitude, longitude: newLongitude),
            lastLocationRequestDate: oldModel.lastLocationRequestDate,
            address: oldModel.address,
            cityId: oldModel.cityId
        )
    }

    /// Обновляет дату последнего запроса локации
    /// - Parameter date: Новая дата запроса
    /// - Returns: Обновленная модель
    public func updatingLastLocationRequestDate(_ date: Date) -> Self {
        Self(
            coordinate: coordinate,
            lastLocationRequestDate: date,
            address: address,
            cityId: cityId
        )
    }

    /// Создает модель с данными геокодирования
    /// - Parameters:
    ///   - address: Адрес площадки
    ///   - cityId: Идентификатор города
    /// - Returns: Обновленная модель
    public func withGeocodingData(address: String, cityId: Int) -> Self {
        Self(
            coordinate: coordinate,
            lastLocationRequestDate: lastLocationRequestDate,
            address: address,
            cityId: cityId
        )
    }

    /// Создает модель с обнуленным адресом для принудительного геокодирования
    /// - Returns: Модель с пустым адресом, остальные поля не изменяются
    public func withoutAddress() -> Self {
        Self(
            coordinate: coordinate,
            lastLocationRequestDate: lastLocationRequestDate,
            address: "",
            cityId: cityId
        )
    }

    public static let empty = Self(
        coordinate: .init(latitude: 0, longitude: 0),
        lastLocationRequestDate: nil,
        address: "",
        cityId: 0
    )
}

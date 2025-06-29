import CoreLocation
import Foundation

public struct GeocodingCache: Sendable, Equatable {
    public let coordinate: CLLocationCoordinate2D
    public let address: String
    public let cityId: Int
    public let date: Date

    public static func == (lhs: GeocodingCache, rhs: GeocodingCache) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude &&
            lhs.address == rhs.address &&
            lhs.cityId == rhs.cityId &&
            lhs.date == rhs.date
    }

    public init(coordinate: CLLocationCoordinate2D, address: String, cityId: Int, date: Date = Date()) {
        self.coordinate = coordinate
        self.address = address
        self.cityId = cityId
        self.date = date
    }

    /// Проверяет актуальность кеша для указанных координат
    /// - Parameters:
    ///   - newCoordinate: Новая координата
    ///   - withinSeconds: Время жизни кэша, по умолчанию 60 секунд
    ///   - withinMeters: Расстояние, в пределах которого координата считается одинаковой, по умолчанию 50 метров
    /// - Returns: Валидность кэша. Если кэш невалидный, его нужно очистить.
    public func isValid(
        for newCoordinate: CLLocationCoordinate2D,
        withinSeconds: TimeInterval = 60,
        withinMeters: CLLocationDistance = 50
    ) -> Bool {
        let timeNotPassed = Date().timeIntervalSince(date) < withinSeconds
        let currentLocation = CLLocation(
            latitude: newCoordinate.latitude,
            longitude: newCoordinate.longitude
        )
        let cachedLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        let distanceIsClose = currentLocation.distance(from: cachedLocation) <= withinMeters
        return timeNotPassed && distanceIsClose
    }
}

import MapKit

/// Модель для удобной работы с координатами
public struct LocationCoordinate: Sendable {
    public let lat: Double
    public let lon: Double

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }

    public init(_ center: CLLocationCoordinate2D) {
        self.lat = center.latitude
        self.lon = center.longitude
    }

    public init(_ region: MKCoordinateRegion) {
        self.lat = region.center.latitude
        self.lon = region.center.longitude
    }

    /// Установлены ли координаты локации
    public var isSpecified: Bool {
        lat != 0 && lon != 0
    }

    public static let empty = Self(.init(latitude: 0, longitude: 0))
}

extension LocationCoordinate: Equatable {
    public static func == (lhs: LocationCoordinate, rhs: LocationCoordinate) -> Bool {
        lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }
}

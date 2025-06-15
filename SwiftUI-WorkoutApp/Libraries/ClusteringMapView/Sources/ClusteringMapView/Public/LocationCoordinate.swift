import MapKit

/// Модель для удобной работы с координатами
public struct LocationCoordinate: Sendable {
    public let lat: Double
    public let lon: Double

    public init(_ center: CLLocationCoordinate2D) {
        self.lat = center.latitude.rounded(to: 2)
        self.lon = center.longitude.rounded(to: 2)
    }

    public init(_ region: MKCoordinateRegion) {
        self.lat = region.center.latitude.rounded(to: 2)
        self.lon = region.center.longitude.rounded(to: 2)
    }

    /// Установлены ли координаты локации
    public var isSpecified: Bool {
        lat != 0 && lon != 0
    }
}

extension LocationCoordinate: Equatable {
    public static func == (lhs: LocationCoordinate, rhs: LocationCoordinate) -> Bool {
        lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }
}

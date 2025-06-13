import CoreLocation

/// Модель для удобной работы с координатами
public struct LocationCoordinate {
    public let lat: Double
    public let lon: Double

    public init(_ regionCenter: CLLocationCoordinate2D) {
        self.lat = Double(regionCenter.latitude).rounded()
        self.lon = Double(regionCenter.longitude).rounded()
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

import CoreLocation

/// Модель для удобной работы с координатами
public struct LocationCoordinates {
    let lat: Double
    let lon: Double

    public init(_ regionCenter: CLLocationCoordinate2D) {
        self.lat = Double(regionCenter.latitude).rounded()
        self.lon = Double(regionCenter.longitude).rounded()
    }

    /// Отличаются ли координаты от другой модели
    public func differs(from model: Self) -> Bool {
        lat != model.lat && lon != model.lon
    }
}

import MapKit

public extension MKCoordinateRegion {
    /// Установлен ли регион
    var isSpecified: Bool {
        center.latitude != 0.0 &&
            center.longitude != 0.0 &&
            span.latitudeDelta > 0.0 &&
            span.longitudeDelta > 0.0
    }
}

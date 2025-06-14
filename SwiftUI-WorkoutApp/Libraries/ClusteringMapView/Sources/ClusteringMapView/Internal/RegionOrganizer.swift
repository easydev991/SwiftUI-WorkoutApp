import MapKit
import OSLog

struct RegionOrganizer {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "RegionOrganizer"
    )
    let old: MKCoordinateRegion
    let new: MKCoordinateRegion

    /// Обновляет регион карты, если нужно
    ///
    /// Про тестирование: https://stackoverflow.com/a/51903928/11830041
    @MainActor
    func updateRegionIfNeeded(for mapView: MKMapView) {
        let oldCoordinate = LocationCoordinate(old.center)
        let newCoordinate = LocationCoordinate(new.center)
        guard newCoordinate.isSpecified, isSpanSpecified else {
            logger.debug("Новый регион не настроен, не обновляем регион")
            return
        }
        guard newCoordinate != oldCoordinate || isSpanDifferent else {
            logger.debug("Новый регион совпадает с предыдущим, не обновляем регион")
            return
        }
        mapView.setRegion(new, animated: true)
    }
}

private extension RegionOrganizer {
    var isSpanSpecified: Bool {
        old.span.latitudeDelta != 0 || old.span.longitudeDelta != 0
    }

    var isSpanDifferent: Bool {
        old.span.latitudeDelta != new.span.latitudeDelta ||
            old.span.longitudeDelta != new.span.longitudeDelta
    }
}

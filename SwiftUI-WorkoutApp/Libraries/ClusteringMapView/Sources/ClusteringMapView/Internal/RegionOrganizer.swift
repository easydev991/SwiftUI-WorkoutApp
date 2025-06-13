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
        let oldCoordinates = LocationCoordinates(old.center)
        let newCoordinates = LocationCoordinates(new.center)
        guard newCoordinates.isSpecified, isSpanSpecified else {
            logger.debug("Новый регион не настроен, не обновляем регион")
            return
        }
        guard newCoordinates.differs(from: oldCoordinates) || isSpanDifferent else {
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

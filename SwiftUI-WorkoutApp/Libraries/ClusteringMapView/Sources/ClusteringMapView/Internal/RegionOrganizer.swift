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
        logger.debug("Собираемся обновить регион, id операции: \(UUID().uuidString)")
        let oldCoordinate = LocationCoordinate(old)
        let newCoordinate = LocationCoordinate(new)
        guard newCoordinate.isSpecified else {
            logger.debug("Новый регион не настроен, не обновляем регион")
            return
        }
        guard newCoordinate != oldCoordinate else {
            logger.debug("Новый регион совпадает с предыдущим, не обновляем регион")
            return
        }
        mapView.setRegion(new, animated: true)
        logger.debug("Обновили регион")
    }
}

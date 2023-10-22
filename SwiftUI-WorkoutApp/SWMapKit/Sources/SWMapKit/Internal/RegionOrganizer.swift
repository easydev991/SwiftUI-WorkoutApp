import MapKit

struct RegionOrganizer {
    let old: MKCoordinateRegion
    let new: MKCoordinateRegion

    /// Обновляет регион карты, если нужно
    func updateRegionIfNeeded(for mapView: MKMapView) {
        let oldCoordinates = LocationCoordinates(old.center)
        let newCoordinates = LocationCoordinates(new.center)
        if newCoordinates.isSpecified, newCoordinates.differs(from: oldCoordinates) {
            mapView.setRegion(new, animated: true)
        }
    }
}

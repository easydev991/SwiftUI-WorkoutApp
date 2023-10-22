import MapKit

struct AnnotationsOrganizer {
    let old: [any MKAnnotation]
    let new: [any MKAnnotation]

    /// Обновляет аннотации на карте, если нужно
    func updateAnnotationsIfNeeded(for mapView: MKMapView) {
        guard !canSkipUpdate, hasDifferences else { return }
        if !old.isEmpty {
            mapView.removeAnnotations(old)
        }
        mapView.addAnnotations(new)
    }

    /// Если нет точек, ничего не делаем
    private var canSkipUpdate: Bool {
        old.isEmpty && new.isEmpty
    }

    /// Сравнивает количество старых и новых точек
    ///
    /// Фильтрует точку с пользователем и кластеры
    private var hasDifferences: Bool {
        let filteredOld = old.filter {
            type(of: $0) != MKClusterAnnotation.self && type(of: $0) != MKUserLocation.self
        }
        return new.count != filteredOld.count
    }
}

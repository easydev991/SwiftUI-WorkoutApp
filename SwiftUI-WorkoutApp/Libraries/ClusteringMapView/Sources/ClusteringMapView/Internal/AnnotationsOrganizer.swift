import MapKit
import OSLog

struct AnnotationsOrganizer {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AnnotationsOrganizer.self)
    )
    let old: [any MKAnnotation]
    let new: [any MKAnnotation]

    /// Обновляет аннотации на карте, если нужно
    @MainActor
    func updateIfNeeded(for mapView: MKMapView) {
        logger.debug("AnnotationsOrganizer.updateIfNeeded вызван: old.count=\(old.count), new.count=\(new.count)")
        guard !canSkipUpdate else {
            logger.debug("Пропускаем обновление: canSkipUpdate=true")
            return
        }
        guard hasDifferences else {
            logger.debug("Пропускаем обновление: hasDifferences=false")
            return
        }
        logger.debug("Обновляем аннотации на карте")
        if !old.isEmpty {
            mapView.removeAnnotations(old)
        }
        mapView.addAnnotations(new)
        logger.debug("Аннотации обновлены: добавлено \(new.count)")
    }

    /// Если нет точек, ничего не делаем
    var canSkipUpdate: Bool {
        old.isEmpty && new.isEmpty
    }

    /// Сравнивает старые и новые аннотации по идентификаторам
    ///
    /// Фильтрует точку с пользователем и кластеры, затем сравнивает идентификаторы
    var hasDifferences: Bool {
        let filteredOld = old.filter {
            type(of: $0) != MKClusterAnnotation.self && type(of: $0) != MKUserLocation.self
        }
        let filteredOldCount = filteredOld.count
        let newCount = new.count

        // Быстрая проверка по количеству
        guard newCount == filteredOldCount else {
            logger.debug("Количество аннотаций изменилось: old=\(filteredOldCount), new=\(newCount)")
            return true
        }

        // Сравнение по идентификаторам (title для ParkAnnotation)
        let oldIdentifiers = Set(filteredOld.compactMap(\.title))
        let newIdentifiers = Set(new.compactMap(\.title))

        let hasDiff = oldIdentifiers != newIdentifiers
        if hasDiff {
            logger.debug("Идентификаторы аннотаций изменились")
        } else {
            logger.debug("Аннотации идентичны, обновление не требуется")
        }
        return hasDiff
    }
}

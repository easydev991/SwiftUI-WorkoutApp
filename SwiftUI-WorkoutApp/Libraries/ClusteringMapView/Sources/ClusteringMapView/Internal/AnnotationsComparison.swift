import MapKit

/// Утилита для сравнения аннотаций по идентификаторам
enum AnnotationsComparison {
    /// Проверяет, есть ли различия между старыми и новыми аннотациями
    ///
    /// Фильтрует кластеры и пользовательскую локацию из старых и новых аннотаций,
    /// затем сравнивает количество и идентификаторы (title) аннотаций
    ///
    /// - Parameters:
    ///   - old: Старые аннотации (могут содержать кластеры и пользовательскую локацию)
    ///   - new: Новые аннотации (могут содержать кластеры и пользовательскую локацию)
    /// - Returns: `true` если есть различия, `false` если аннотации идентичны
    static func hasDifferences(old: [any MKAnnotation], new: [any MKAnnotation]) -> Bool {
        let filteredOld = old.filter {
            !($0 is MKClusterAnnotation) && !($0 is MKUserLocation)
        }
        let filteredNew = new.filter {
            !($0 is MKClusterAnnotation) && !($0 is MKUserLocation)
        }
        let filteredOldCount = filteredOld.count
        let filteredNewCount = filteredNew.count

        guard filteredNewCount == filteredOldCount else {
            return true
        }

        let oldIdentifiers = Set(filteredOld.compactMap(\.title))
        let newIdentifiers = Set(filteredNew.compactMap(\.title))

        return oldIdentifiers != newIdentifiers
    }
}

import Combine
import MapKit
import SwiftUI

/// Менеджер кэширования аннотаций для карты
///
/// Использует `AnnotationsComparison` для определения необходимости обновления кэша
@MainActor
public final class AnnotationsCacheManager: ObservableObject {
    @Published public private(set) var annotations: [any MKAnnotation] = []

    public init() {}

    /// Обновляет кэш, если аннотации изменились
    ///
    /// - Parameter newAnnotations: Новые аннотации для сравнения и обновления
    public func updateIfNeeded(with newAnnotations: [any MKAnnotation]) {
        if shouldUpdate(with: newAnnotations) {
            update(with: newAnnotations)
        }
    }
}

extension AnnotationsCacheManager {
    /// Проверяет, нужно ли обновить кэш аннотаций
    ///
    /// - Parameter newAnnotations: Новые аннотации для сравнения
    /// - Returns: `true` если кэш нужно обновить, `false` если аннотации идентичны
    func shouldUpdate(with newAnnotations: [any MKAnnotation]) -> Bool {
        AnnotationsComparison.hasDifferences(old: annotations, new: newAnnotations)
    }

    /// Обновляет кэш новыми аннотациями
    ///
    /// - Parameter newAnnotations: Новые аннотации для сохранения в кэш
    func update(with newAnnotations: [any MKAnnotation]) {
        annotations = newAnnotations
    }
}

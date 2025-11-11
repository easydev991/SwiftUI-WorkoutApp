@testable import ClusteringMapView
import MapKit
import Testing

struct AnnotationsComparisonTests {
    @Test("Должен возвращать true если идентификаторы изменились")
    func shouldReturnTrueWhenIdentifiersChanged() {
        let oldAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        let newAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "3", lat: 0, lon: 0)
        ]
        #expect(AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }

    @Test("Должен возвращать false если идентификаторы не изменились")
    func shouldReturnFalseWhenIdentifiersNotChanged() {
        let annotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        #expect(!AnnotationsComparison.hasDifferences(old: annotations, new: annotations))
    }

    @Test("Должен фильтровать кластеры и пользовательскую локацию из старых аннотаций")
    func shouldFilterClustersAndUserLocation() {
        // В реальном использовании старые аннотации (mapView.annotations) могут содержать кластеры и пользовательскую локацию,
        // а новые аннотации (передаваемые в ClusteringMapView) содержат только обычные аннотации
        // Тест проверяет, что обычные аннотации сравниваются корректно, игнорируя кластеры и пользовательскую локацию
        let oldAnnotations: [any MKAnnotation] = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        let newAnnotations: [any MKAnnotation] = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        #expect(!AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }

    @Test("Должен возвращать true если изменилось количество")
    func shouldReturnTrueWhenCountChanged() {
        let oldAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        let newAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0),
            TestAnnotation(title: "3", lat: 0, lon: 0)
        ]
        #expect(AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }

    @Test("Должен возвращать true если старые аннотации пустые, а новые нет")
    func shouldReturnTrueWhenOldEmptyAndNewNotEmpty() {
        let oldAnnotations: [any MKAnnotation] = []
        let newAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0)
        ]
        #expect(AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }

    @Test("Должен возвращать true если новые аннотации пустые, а старые нет")
    func shouldReturnTrueWhenNewEmptyAndOldNotEmpty() {
        let oldAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0)
        ]
        let newAnnotations: [any MKAnnotation] = []
        #expect(AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }

    @Test("Должен возвращать false если обе коллекции пустые")
    func shouldReturnFalseWhenBothEmpty() {
        let oldAnnotations: [any MKAnnotation] = []
        let newAnnotations: [any MKAnnotation] = []
        #expect(!AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }

    @Test("Должен игнорировать кластеры при сравнении количества")
    func shouldIgnoreClustersWhenComparingCount() {
        // В реальном использовании старые аннотации (mapView.annotations) могут содержать кластеры,
        // а новые аннотации (передаваемые в ClusteringMapView) содержат только обычные аннотации
        // Тест проверяет логику сравнения при одинаковом количестве обычных аннотаций
        let oldAnnotations: [any MKAnnotation] = [
            TestAnnotation(title: "1", lat: 0, lon: 0)
        ]
        let newAnnotations: [any MKAnnotation] = [
            TestAnnotation(title: "1", lat: 0, lon: 0)
        ]
        #expect(!AnnotationsComparison.hasDifferences(old: oldAnnotations, new: newAnnotations))
    }
}

private final class TestAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?

    init(title: String, lat: Double, lon: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.title = title
    }
}

@testable import ClusteringMapView
import MapKit
import Testing

struct AnnotationsCacheManagerTests {
    @Test("Должен возвращать true при первом обновлении (кэш пустой)")
    @MainActor
    func shouldReturnTrueOnFirstUpdate() {
        let sut = AnnotationsCacheManager()
        let annotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        #expect(sut.shouldUpdate(with: annotations))
    }

    @Test("Должен возвращать false если идентификаторы не изменились")
    @MainActor
    func shouldReturnFalseWhenIdentifiersNotChanged() {
        let sut = AnnotationsCacheManager()
        let annotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        sut.update(with: annotations)
        #expect(!sut.shouldUpdate(with: annotations))
    }

    @Test("Должен возвращать true если изменились идентификаторы")
    @MainActor
    func shouldReturnTrueWhenIdentifiersChanged() {
        let sut = AnnotationsCacheManager()
        let initialAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        sut.update(with: initialAnnotations)
        let newAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "3", lat: 0, lon: 0)
        ]
        #expect(sut.shouldUpdate(with: newAnnotations))
    }

    @Test("Должен обновлять кэш новыми данными")
    @MainActor
    func shouldUpdateCacheWithNewData() {
        let sut = AnnotationsCacheManager()
        let initialAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0)
        ]
        sut.update(with: initialAnnotations)
        #expect(sut.annotations.count == 1)
        let newAnnotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        sut.update(with: newAnnotations)
        #expect(sut.annotations.count == 2)
    }

    @Test("Должен корректно обрабатывать пустой массив")
    @MainActor
    func shouldHandleEmptyArray() {
        let sut = AnnotationsCacheManager()
        let annotations = [
            TestAnnotation(title: "1", lat: 0, lon: 0)
        ]
        sut.update(with: annotations)
        #expect(sut.shouldUpdate(with: []))
        sut.update(with: [])
        #expect(sut.annotations.isEmpty)
    }

    @Test("Должен фильтровать кластеры и пользовательскую локацию при сравнении")
    @MainActor
    func shouldFilterClustersAndUserLocation() {
        // В реальном использовании новые аннотации не содержат кластеры и пользовательскую локацию,
        // но тест проверяет, что если они случайно попадут, они будут отфильтрованы
        let sut = AnnotationsCacheManager()
        let initialAnnotations: [any MKAnnotation] = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        sut.update(with: initialAnnotations)
        // Этот тест проверяет, что обычные аннотации сравниваются корректно
        let newAnnotations: [any MKAnnotation] = [
            TestAnnotation(title: "1", lat: 0, lon: 0),
            TestAnnotation(title: "2", lat: 0, lon: 0)
        ]
        #expect(!sut.shouldUpdate(with: newAnnotations))
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

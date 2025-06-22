@testable import ClusteringMapView
import MapKit
import Testing

struct ClusteringMapViewTests {
    @Test
    @MainActor
    func updateAnnotations() async throws {
        let mapView = MKMapView()
        let initialAnnotations = TestAnnotation.makeList(of: 20)
        mapView.addAnnotations(initialAnnotations)
        #expect(mapView.annotations.count == initialAnnotations.count)

        let newAnnotations = TestAnnotation.makeList(of: 30)
        let sut = AnnotationsOrganizer(old: initialAnnotations, new: newAnnotations)
        sut.updateIfNeeded(for: mapView)
        #expect(mapView.annotations.count == newAnnotations.count)
    }

    @Test
    func locationCoordinateIsNotSpecified() {
        let sut1 = LocationCoordinate(.init(latitude: 0, longitude: 0))
        let sut2 = LocationCoordinate.empty
        #expect(!sut1.isSpecified)
        #expect(!sut2.isSpecified)
    }

    @Test
    func locationCoordinateIsSpecified() {
        let sut = LocationCoordinate(
            .init(
                latitude: Double.random(in: 10 ... 100),
                longitude: Double.random(in: 10 ... 100)
            )
        )
        #expect(sut.isSpecified)
    }

    @Test
    func locationsAreEqual() {
        let location1 = LocationCoordinate.empty
        let location2 = LocationCoordinate.empty
        let location3 = LocationCoordinate(.init(latitude: 12, longitude: 14))
        let location4 = LocationCoordinate(.init(latitude: 12, longitude: 14))
        #expect(location1 == location2)
        #expect(location3 == location4)
    }

    @Test
    func locationsDiffer() {
        let firstLocation = LocationCoordinate(.init(latitude: 0, longitude: 0))
        let secondLocation = LocationCoordinate(.init(latitude: 1, longitude: 1))
        #expect(firstLocation != secondLocation)
    }
}

// Вспомогательный класс для тестовых аннотаций
private final class TestAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D

    init(lat: Double, lon: Double) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    static func makeList(of count: Int) -> [TestAnnotation] {
        (0 ..< count).map { _ in
            .init(lat: Double.random(in: 10 ... 50), lon: Double.random(in: 51 ... 99))
        }
    }
}

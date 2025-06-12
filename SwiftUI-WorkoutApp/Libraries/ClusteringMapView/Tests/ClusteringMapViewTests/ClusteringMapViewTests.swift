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
        sut.updateAnnotationsIfNeeded(for: mapView)
        #expect(mapView.annotations.count == newAnnotations.count)
    }

    @Test
    func locationCoordinatesIsNotSpecified() {
        let sut = LocationCoordinates(.init(latitude: 0, longitude: 0))
        #expect(!sut.isSpecified)
    }

    @Test
    func locationCoordinatesIsSpecified() {
        let sut = LocationCoordinates(
            .init(
                latitude: Double.random(in: 10 ... 100),
                longitude: Double.random(in: 10 ... 100)
            )
        )
        #expect(sut.isSpecified)
    }

    @Test
    func locationsAreEqual() {
        let firstLocation = LocationCoordinates(.init(latitude: 0, longitude: 0))
        let secondLocation = LocationCoordinates(.init(latitude: 0, longitude: 0))
        #expect(!firstLocation.differs(from: secondLocation))
    }

    @Test
    func locationsDiffer() {
        let firstLocation = LocationCoordinates(.init(latitude: 0, longitude: 0))
        let secondLocation = LocationCoordinates(.init(latitude: 1, longitude: 1))
        #expect(firstLocation.differs(from: secondLocation))
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

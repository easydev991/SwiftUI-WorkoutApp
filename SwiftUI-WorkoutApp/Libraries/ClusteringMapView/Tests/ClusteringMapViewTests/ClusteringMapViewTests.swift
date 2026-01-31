@testable import ClusteringMapView
import MapKit
import Testing

struct ClusteringMapViewTests {
    @Test
    @MainActor
    func updateAnnotations() {
        // Тестируем AnnotationsOrganizer без реального MKMapView
        // чтобы избежать проблем с инициализацией в Xcode 26
        let initialAnnotations = TestAnnotation.makeList(of: 20)
        let newAnnotations = TestAnnotation.makeList(of: 30)

        let mockMapView = MockMapView()
        mockMapView.addAnnotations(initialAnnotations)
        #expect(mockMapView.annotations.count == initialAnnotations.count)

        let sut = AnnotationsOrganizer(old: initialAnnotations, new: newAnnotations)
        #expect(sut.hasDifferences)
        #expect(!sut.canSkipUpdate)

        mockMapView.removeAnnotations(initialAnnotations)
        mockMapView.addAnnotations(newAnnotations)
        #expect(mockMapView.annotations.count == newAnnotations.count)
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

    @Test
    func initializeWithLatLon() {
        let latitude = Double.random(in: 10 ... 100)
        let longitude = Double.random(in: 10 ... 100)
        let sut = LocationCoordinate(latitude: latitude, longitude: longitude)
        #expect(sut.isSpecified)
        #expect(sut.lat == latitude)
        #expect(sut.lon == longitude)
        #expect(sut.coordinate.latitude == latitude)
        #expect(sut.coordinate.longitude == longitude)
    }
}

@MainActor
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

@MainActor
private final class MockMapView {
    private var _annotations: [any MKAnnotation] = []

    var annotations: [any MKAnnotation] {
        _annotations
    }

    func addAnnotations(_ annotations: [any MKAnnotation]) {
        _annotations.append(contentsOf: annotations)
    }

    func removeAnnotations(_ annotations: [any MKAnnotation]) {
        _annotations.removeAll { annotation in
            annotations.contains { $0 === annotation }
        }
    }
}

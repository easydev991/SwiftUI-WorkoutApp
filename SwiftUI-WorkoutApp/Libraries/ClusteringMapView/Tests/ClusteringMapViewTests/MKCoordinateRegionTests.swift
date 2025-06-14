import ClusteringMapView
import MapKit
import Testing

struct MKCoordinateRegionTests {
    @Test("Регион установлен")
    func validRegion() {
        let region = MKCoordinateRegion(
            center: .init(latitude: 55.7558, longitude: 37.6173),
            span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        #expect(region.isSpecified)
    }

    @Test("Регион по умолчанию не установлен")
    func defaultRegion() {
        let region = MKCoordinateRegion()
        #expect(!region.isSpecified)
    }

    @Test("Нулевая широта")
    func zeroLatitude() {
        let region = MKCoordinateRegion(
            center: .init(latitude: 0, longitude: 37.6173),
            span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        #expect(!region.isSpecified)
    }

    @Test("Нулевая долгота")
    func zeroLongitude() {
        // Given
        let region = MKCoordinateRegion(
            center: .init(latitude: 55.7558, longitude: 0),
            span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        #expect(!region.isSpecified)
    }

    @Test("Нулевой размах по широте")
    func zeroLatitudeDelta() {
        let region = MKCoordinateRegion(
            center: .init(latitude: 55.7558, longitude: 37.6173),
            span: .init(latitudeDelta: 0, longitudeDelta: 0.5)
        )
        #expect(!region.isSpecified)
    }

    @Test("Отрицательный размах по широте")
    func negativeLatitudeDelta() {
        let region = MKCoordinateRegion(
            center: .init(latitude: 55.7558, longitude: 37.6173),
            span: .init(latitudeDelta: -0.5, longitudeDelta: 0.5)
        )
        #expect(!region.isSpecified)
    }

    @Test("Нулевой размах по долготе")
    func zeroLongitudeDelta() {
        let region = MKCoordinateRegion(
            center: .init(latitude: 55.7558, longitude: 37.6173),
            span: .init(latitudeDelta: 0.5, longitudeDelta: 0)
        )
        #expect(!region.isSpecified)
    }

    @Test("Отрицательный размах по долготе")
    func negativeLongitudeDelta() {
        let region = MKCoordinateRegion(
            center: .init(latitude: 55.7558, longitude: 37.6173),
            span: .init(latitudeDelta: 0.5, longitudeDelta: -0.5)
        )
        #expect(!region.isSpecified)
    }
}

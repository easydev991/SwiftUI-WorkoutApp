import CoreLocation
@testable import SWModels
import Testing

struct GeocodingCacheTests {
    @Test
    func isValidWithinTimeAndDistance() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176)
        let cache = GeocodingCache(
            coordinate: coordinate,
            address: "Test Address",
            cityId: 1,
            date: Date().addingTimeInterval(-30) // 30 секунд назад
        )
        #expect(cache.isValid(for: coordinate), "Для той же точки должен быть валидным")
        let nearbyCoordinate = CLLocationCoordinate2D(latitude: 55.7559, longitude: 37.6177)
        #expect(cache.isValid(for: nearbyCoordinate), "В пределах 50 метров должен быть валидным")
    }

    @Test
    func isValidExpiredTime() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176)
        let cache = GeocodingCache(
            coordinate: coordinate,
            address: "Test Address",
            cityId: 1,
            date: Date().addingTimeInterval(-120) // 2 минуты назад
        )
        #expect(!cache.isValid(for: coordinate))
    }

    @Test
    func isValidTooFarDistance() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176)
        let cache = GeocodingCache(
            coordinate: coordinate,
            address: "Test Address",
            cityId: 1,
            date: Date().addingTimeInterval(-30)
        )
        let farCoordinate = CLLocationCoordinate2D(latitude: 55.7600, longitude: 37.6200)
        #expect(!cache.isValid(for: farCoordinate), "Дальше 50 метров должен быть невалидным")
    }
}

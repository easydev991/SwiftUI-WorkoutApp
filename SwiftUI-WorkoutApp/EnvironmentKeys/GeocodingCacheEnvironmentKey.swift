import CoreLocation
import SwiftUI
import SWModels

@MainActor
struct GeocodingCacheUpdateKey: @preconcurrency EnvironmentKey {
    static let defaultValue: (
        _ address: String,
        _ cityId: Int,
        _ coordinate: CLLocationCoordinate2D
    ) -> Void = { _, _, _ in }
}

extension EnvironmentValues {
    /// Замыкание для обновления кэша геогодирования
    var updateGeocodingCache: (
        _ address: String,
        _ cityId: Int,
        _ coordinate: CLLocationCoordinate2D
    ) -> Void {
        get { self[GeocodingCacheUpdateKey.self] }
        set { self[GeocodingCacheUpdateKey.self] = newValue }
    }
}

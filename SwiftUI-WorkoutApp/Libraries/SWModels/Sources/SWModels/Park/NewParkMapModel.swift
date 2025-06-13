import CoreLocation
import Foundation

public struct NewParkMapModel: Sendable, Equatable {
    public var address: String
    public var latitude: Double
    public var longitude: Double
    public var cityId: Int

    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    public init(address: String, coordinate: CLLocationCoordinate2D, cityId: Int) {
        self.address = address
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.cityId = cityId
    }

    public static let empty = Self(
        address: "",
        coordinate: .init(latitude: 0, longitude: 0),
        cityId: 0
    )
}

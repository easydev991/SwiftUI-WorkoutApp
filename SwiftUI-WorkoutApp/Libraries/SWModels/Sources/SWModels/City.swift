import CoreLocation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "City")

public struct City: Codable, Identifiable, Hashable, Sendable {
    public let id, name, lat, lon: String

    public init(id: String) {
        self.id = id
        self.name = ""
        self.lat = ""
        self.lon = ""
    }

    public init(id: String, name: String, lat: String, lon: String) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
    }

    /// Москва
    public static var defaultCity: Self {
        .init(id: "1", name: "Москва", lat: "55.753215", lon: "37.622504")
    }

    /// Признак наличия валидных координат для города
    public var hasValidCoordinates: Bool {
        coordinate2D != nil
    }
}

public extension City {
    /// Координаты города как `CLLocationCoordinate2D`
    var coordinate2D: CLLocationCoordinate2D? {
        guard let latitude = Double(lat), let longitude = Double(lon) else {
            logger.debug("Не смогли определить координаты города \(name): lat \(lat), lon \(lon)")
            return nil
        }
        return .init(latitude: latitude, longitude: longitude)
    }
}

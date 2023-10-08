public struct City: Codable, Identifiable, Hashable {
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
}

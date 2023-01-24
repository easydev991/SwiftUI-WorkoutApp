import Foundation

struct City: Codable, Identifiable, Hashable {
    let id, name, lat, lon: String

    init(id: String) {
        self.id = id
        self.name = ""
        self.lat = ""
        self.lon = ""
    }

    init(id: String, name: String, lat: String, lon: String) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
    }

    static var defaultCity: Self {
        .init(id: "1", name: "Москва", lat: "55.753215", lon: "37.622504")
    }
}

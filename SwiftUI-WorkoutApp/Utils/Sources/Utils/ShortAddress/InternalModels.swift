struct Country: Codable {
    let id, name: String
    let cities: [City]
}

struct City: Codable {
    let id, name, lat, lon: String
}

import Foundation

internal struct Country: Codable {
    let id, name: String
    let cities: [City]
}

internal struct City: Codable {
    let id, name, lat, lon: String
}

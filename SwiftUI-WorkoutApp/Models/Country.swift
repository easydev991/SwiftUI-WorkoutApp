import Foundation

struct Country: Codable, Identifiable, Hashable {
    let cities: [City]
    var id, name: String

    static var defaultCountry: Self {
        .init(cities: [], id: "17", name: "Россия")
    }
}

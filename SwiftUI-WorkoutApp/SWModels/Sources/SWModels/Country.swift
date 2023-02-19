public struct Country: Codable, Identifiable, Hashable {
    public let cities: [City]
    public var id, name: String

    public static var defaultCountry: Self {
        .init(cities: [], id: "17", name: "Россия")
    }
}

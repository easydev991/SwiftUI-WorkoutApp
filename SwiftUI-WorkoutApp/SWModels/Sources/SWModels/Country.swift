public struct Country: Codable, Identifiable, Hashable, Sendable {
    public let cities: [City]
    public var id, name: String

    /// Россия
    public static var defaultCountry: Self {
        .init(cities: [], id: "17", name: "Россия")
    }
}

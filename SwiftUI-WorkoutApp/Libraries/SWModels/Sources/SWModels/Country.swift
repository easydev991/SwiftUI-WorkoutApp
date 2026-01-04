public struct Country: Codable, Identifiable, Hashable, Sendable {
    public let cities: [City]
    public var id, name: String

    /// Россия
    public static var defaultCountry: Self {
        .init(cities: [], id: "17", name: "Россия")
    }
}

public extension Country {
    /// Подсказка о необходимости указать страну для создания площадок
    var hint: String? {
        guard id != "0" else {
            return String(localized: .editProfileCountryHint)
        }
        return nil
    }
}

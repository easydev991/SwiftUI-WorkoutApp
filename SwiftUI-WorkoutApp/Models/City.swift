import Foundation

struct City: Codable, Identifiable, Hashable {
    let id, name: String

    static var defaultCity: Self {
        .init(id: "1", name: "Москва")
    }
}

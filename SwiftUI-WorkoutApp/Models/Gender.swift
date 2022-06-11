import Foundation

enum Gender: String, CaseIterable, CustomStringConvertible, Codable {
    case male = "Мужской"
    case female = "Женский"

    init(_ code: Int?) {
        self = code == .zero ? .male : .female
    }

    var code: Int { self == .male ? .zero : 1 }

    var description: String {
        self == .male ? "Мужчина" : "Женщина"
    }
}

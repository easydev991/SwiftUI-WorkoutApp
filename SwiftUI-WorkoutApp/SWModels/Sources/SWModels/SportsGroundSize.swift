public enum SportsGroundSize: String, CaseIterable {
    case small = "Маленькая"
    case medium = "Средняя"
    case large = "Большая"

    public init(id: Int) {
        switch id {
        case 1: self = .small
        case 2: self = .medium
        default: self = .large // id = 3
        }
    }

    public var code: Int {
        switch self {
        case .small: 1
        case .medium: 2
        case .large: 3
        }
    }
}

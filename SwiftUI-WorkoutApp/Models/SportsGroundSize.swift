enum SportsGroundSize: String, CaseIterable {
    case small = "Маленькая"
    case medium = "Средняя"
    case large = "Большая"

    init(id: Int) {
        switch id {
        case 1: self = .small
        case 2: self = .medium
        default: self = .large // id = 3
        }
    }

    var code: Int {
        switch self {
        case .small: return 1
        case .medium: return 2
        case .large: return 3
        }
    }
}

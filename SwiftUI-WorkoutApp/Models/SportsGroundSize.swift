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
}

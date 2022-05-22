struct SportsGroundSize {
    let size: Size

    enum Size: String {
        case small = "Маленькая"
        case medium = "Средняя"
        case large = "Большая"
    }

    init(id: Int) {
        switch id {
        case 1: size = .small
        case 2: size = .medium
        default: size = .large // id = 3
        }
    }
}

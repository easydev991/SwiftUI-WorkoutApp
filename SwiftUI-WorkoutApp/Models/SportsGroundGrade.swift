enum SportsGroundGrade: String, CaseIterable {
    case soviet = "Советская"
    case modern = "Современная"
    case collars = "Хомуты"
    case underTheHood = "Под навесом"
    case legendary = "Легендарная"
    case broken = "Разрушена"
    case other = "Разное"

    init(id: Int) {
        switch id {
        case 1: self = .soviet
        case 2: self = .modern
        case 3: self = .collars
        case 4: self = .underTheHood
        case 5: self = .broken
        case 6: self = .legendary
        default: self = .other // id = 7
        }
    }
}

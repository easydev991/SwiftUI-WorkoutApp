enum SportsGroundGrade: String, CaseIterable {
    case soviet = "Советская"
    case modern = "Современная"
    case collars = "Хомуты"
    case underTheHood = "Под навесом"
    case legendary = "Легендарная"

    init(id: Int) {
        switch id {
        case 1: self = .soviet
        case 2: self = .modern
        case 3: self = .collars
        case 4: self = .underTheHood
        default: self = .legendary
        }
    }

    var code: Int {
        switch self {
        case .soviet: return 1
        case .modern: return 2
        case .collars: return 3
        case .underTheHood: return 4
        case .legendary: return 6
        }
    }
}

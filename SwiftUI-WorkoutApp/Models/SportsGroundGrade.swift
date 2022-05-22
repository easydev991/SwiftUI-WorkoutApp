struct SportsGroundGrade {
    let grade: Grade

    enum Grade: String {
        case soviet = "Советская"
        case modern = "Современная"
        case collars = "Хомуты"
        case underTheHood = "Под навесом"
        case legendary = "Легендарная"
        case broken = "Разрушена"
        case other = "Разное"
    }

    init(id: Int) {
        switch id {
        case 1: grade = .soviet
        case 2: grade = .modern
        case 3: grade = .collars
        case 4: grade = .underTheHood
        case 5: grade = .broken
        case 6: grade = .legendary
        default: grade = .other // id = 7
        }
    }
}

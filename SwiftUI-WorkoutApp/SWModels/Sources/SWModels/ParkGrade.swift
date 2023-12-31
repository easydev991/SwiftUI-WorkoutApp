public enum ParkGrade: String, CaseIterable {
    case soviet = "Советская"
    case modern = "Современная"
    case collars = "Хомуты"
    case legendary = "Легендарная"

    public init(id: Int) {
        switch id {
        case 1: self = .soviet
        case 2: self = .modern
        case 3: self = .collars
        default: self = .legendary
        }
    }

    public var code: Int {
        switch self {
        case .soviet: 1
        case .modern: 2
        case .collars: 3
        case .legendary: 6
        }
    }
}

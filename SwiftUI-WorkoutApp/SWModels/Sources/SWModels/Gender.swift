public enum Gender: String, CaseIterable, CustomStringConvertible, Codable {
    case unspecified = "Не указан"
    case male = "Мужской"
    case female = "Женский"

    public init?(_ code: Int) {
        switch code {
        case -1:
            self = .unspecified
        case 0:
            self = .male
        case 1:
            self = .female
        default:
            return nil
        }
    }

    public var code: Int {
        switch self {
        case .unspecified:
            -1
        case .male:
            0
        case .female:
            1
        }
    }

    public var description: String {
        switch self {
        case .unspecified:
            ""
        case .male:
            "Мужчина"
        case .female:
            "Женщина"
        }
    }
}

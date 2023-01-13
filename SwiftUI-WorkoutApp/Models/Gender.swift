import Foundation

enum Gender: String, CaseIterable, CustomStringConvertible, Codable {
    case unspecified = "Не указан"
    case male = "Мужской"
    case female = "Женский"

    init?(_ code: Int) {
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

    var code: Int {
        switch self {
        case .unspecified:
            return -1
        case .male:
            return 0
        case .female:
            return 1
        }
    }

    var description: String {
        switch self {
        case .unspecified:
            return ""
        case .male:
            return "Мужчина"
        case .female:
            return "Женщина"
        }
    }
}

extension Gender {
    static let possibleGenders = [Gender.male, Gender.female]
}

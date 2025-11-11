import Foundation

public enum Gender: CaseIterable, CustomStringConvertible, Codable {
    case unspecified
    case male
    case female

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

    public var affiliation: String {
        switch self {
        case .unspecified: String(localized: .genderNotSpecifiedAfiliation)
        case .male: String(localized: .genderMaleAffiliation)
        case .female: String(localized: .genderFemaleAffiliation)
        }
    }

    public var description: String {
        switch self {
        case .unspecified: ""
        case .male: String(localized: .genderMale)
        case .female: String(localized: .genderFemale)
        }
    }
}

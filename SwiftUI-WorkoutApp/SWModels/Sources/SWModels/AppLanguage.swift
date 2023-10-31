/// Язык для текстов в приложении
public enum AppLanguage: String, CaseIterable {
    case rus = "Русский"
    case eng = "Английский"

    public init?(rawValue: String) {
        switch rawValue {
        case "Русский", "Russian", "ru":
            self = .rus
        case "Английский", "English", "en":
            self = .eng
        default: return nil
        }
    }

    public var code: String {
        self == .rus ? "ru" : "en"
    }
}

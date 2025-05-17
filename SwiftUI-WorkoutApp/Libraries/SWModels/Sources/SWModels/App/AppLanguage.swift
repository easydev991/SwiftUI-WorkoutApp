import SwiftUI

public enum AppLanguage: CaseIterable, Identifiable {
    public var id: Self { self }
    case russian
    case english

    public var title: String {
        switch self {
        case .russian: NSLocalizedString("Russian", bundle: .module, comment: "")
        case .english: NSLocalizedString("English", bundle: .module, comment: "")
        }
    }

    public static func makeCurrentValue(_ localeIdentifier: String) -> AppLanguage {
        let isRussian = localeIdentifier.split(separator: "_").first == "ru"
        return isRussian ? .russian : .english
    }
}

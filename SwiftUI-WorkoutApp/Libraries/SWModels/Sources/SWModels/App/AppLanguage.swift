import SwiftUI

public enum AppLanguage: CaseIterable, Identifiable {
    public var id: Self { self }
    case russian
    case english

    public var title: String {
        switch self {
        case .russian: String(localized: .russian)
        case .english: String(localized: .english)
        }
    }

    public static func makeCurrentValue(_ localeIdentifier: String) -> AppLanguage {
        let isRussian = localeIdentifier.split(separator: "_").first == "ru"
        return isRussian ? .russian : .english
    }
}

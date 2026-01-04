import Foundation
import SwiftUI

public enum AppColorTheme: Int, CaseIterable, CustomStringConvertible, Identifiable {
    public var id: Int { rawValue }
    case dark = 0
    case light = 1
    case system = 2

    public var description: String {
        switch self {
        case .dark: String(localized: .appThemeDark)
        case .light: String(localized: .appThemeLight)
        case .system: String(localized: .appThemeSystem)
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}

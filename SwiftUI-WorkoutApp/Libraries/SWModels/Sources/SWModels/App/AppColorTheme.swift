import Foundation

public enum AppColorTheme: Int, CaseIterable, CustomStringConvertible, Identifiable {
    public var id: Int { rawValue }
    case dark = 0
    case light = 1
    case system = 2

    public var description: String {
        switch self {
        case .dark: NSLocalizedString("AppTheme.Dark", bundle: .module, comment: "")
        case .light: NSLocalizedString("AppTheme.Light", bundle: .module, comment: "")
        case .system: NSLocalizedString("AppTheme.System", bundle: .module, comment: "")
        }
    }
}

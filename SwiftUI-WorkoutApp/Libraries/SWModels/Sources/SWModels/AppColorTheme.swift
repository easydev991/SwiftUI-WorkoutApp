import Foundation

public enum AppColorTheme: String, CaseIterable, Identifiable {
    public var id: String { rawValue }
    case dark = "Темная тема"
    case light = "Светлая тема"
    case system = "Как в системе"
}

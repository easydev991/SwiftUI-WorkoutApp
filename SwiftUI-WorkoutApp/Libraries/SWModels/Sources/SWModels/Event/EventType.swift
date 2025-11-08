import Foundation

/// Тип мероприятий (планируемые/прошедшие)
public enum EventType: CaseIterable, Equatable, CustomStringConvertible, Sendable {
    case future
    case past

    public var description: String {
        switch self {
        case .future: String(localized: .eventTypeFuture)
        case .past: String(localized: .eventTypePast)
        }
    }
}

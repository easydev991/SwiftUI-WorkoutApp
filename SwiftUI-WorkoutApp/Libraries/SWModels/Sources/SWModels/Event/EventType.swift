import Foundation

/// Тип мероприятий (планируемые/прошедшие)
public enum EventType: CaseIterable, Equatable, CustomStringConvertible, Sendable {
    case future
    case past

    public var description: String {
        switch self {
        case .future: NSLocalizedString("EventType.Future", bundle: .module, comment: "")
        case .past: NSLocalizedString("EventType.Past", bundle: .module, comment: "")
        }
    }
}

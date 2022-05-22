import Foundation

extension Optional where Wrapped == String {
    var valueOrEmpty: String {
        if let unwrapped = self {
            return unwrapped
        } else {
            return ""
        }
    }
}

extension Optional where Wrapped == Int {
    var valueOrZero: Int {
        if let unwrapped = self {
            return unwrapped
        } else {
            return .zero
        }
    }
}

extension Optional where Wrapped == Bool {
    var isTrue: Bool {
        switch self {
        case let .some(value): return value
        case .none: return false
        }
    }
}

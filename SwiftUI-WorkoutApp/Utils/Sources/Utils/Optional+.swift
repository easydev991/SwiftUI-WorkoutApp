import Foundation

public extension String? {
    var valueOrEmpty: String {
        if let unwrapped = self {
            return unwrapped
        } else {
            return ""
        }
    }
}

public extension Int? {
    var valueOrZero: Int {
        if let unwrapped = self {
            return unwrapped
        } else {
            return .zero
        }
    }
}

public extension Bool? {
    var isTrue: Bool {
        switch self {
        case let .some(value): return value
        case .none: return false
        }
    }
}

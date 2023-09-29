import Foundation

public extension String? {
    var valueOrEmpty: String {
        if let unwrapped = self {
            unwrapped
        } else {
            ""
        }
    }
}

public extension Int? {
    var valueOrZero: Int {
        if let unwrapped = self {
            unwrapped
        } else {
            .zero
        }
    }
}

public extension Bool? {
    var isTrue: Bool {
        switch self {
        case let .some(value): value
        case .none: false
        }
    }
}

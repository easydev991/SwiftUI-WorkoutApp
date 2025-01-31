import Foundation

extension Date: @retroactive RawRepresentable {
    public var rawValue: String {
        String(timeIntervalSinceReferenceDate)
    }

    public init?(rawValue: String) {
        guard let interval = Double(rawValue) else { return nil }
        self = Date(timeIntervalSinceReferenceDate: interval)
    }
}

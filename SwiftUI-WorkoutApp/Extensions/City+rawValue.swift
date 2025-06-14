import Foundation
import SWModels

extension City: @retroactive RawRepresentable {
    public var rawValue: String { name }

    public init?(rawValue: String) {
        do {
            self = try SWAddress.findCity(with: rawValue)
        } catch {
            return nil
        }
    }
}

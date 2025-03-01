import Foundation
import SwiftUI

@propertyWrapper
public struct KeychainWrapper: DynamicProperty {
    private let label: String
    private let storage = SecureStorage()

    public init(_ label: String) {
        self.label = label
    }

    public var wrappedValue: AuthData? {
        get { storage.getCredentials(with: label) }
        set {
            if let newValue {
                storage.updateCredentials(newValue, with: label)
            } else {
                storage.deleteCredentials(with: label)
            }
        }
    }
}

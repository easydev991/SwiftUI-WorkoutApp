import Combine
import Foundation
import SwiftUI

@propertyWrapper
public struct KeychainWrapper: DynamicProperty {
    private let label: String
    private let storage = SecureStorage()
    private let subject: CurrentValueSubject<AuthData?, Never>

    public init(_ label: String) {
        self.label = label
        self.subject = CurrentValueSubject(nil)
        subject.send(storage.getCredentials(with: label))
    }

    public var wrappedValue: AuthData? {
        get { storage.getCredentials(with: label) }
        set {
            if let newValue {
                storage.updateCredentials(newValue, with: label)
            } else {
                storage.deleteCredentials(with: label)
            }
            subject.send(newValue)
        }
    }

    public var projectedValue: AnyPublisher<AuthData?, Never> {
        subject.eraseToAnyPublisher()
    }
}

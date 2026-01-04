import Combine
import Foundation
import SwiftUI
import SWKeychain
import SWNetworkClient

@MainActor
final class MockAuthHelperForDefaultsService: ObservableObject, AuthHelper {
    private(set) var triggerLogoutCallCount = 0

    @Published private(set) var authData: AuthData?

    var authToken: String? {
        authData?.token
    }

    var authTokenPublisher: AnyPublisher<String?, Never> {
        $authData.map { $0?.token }.eraseToAnyPublisher()
    }

    init(authData: AuthData? = nil) {
        self.authData = authData
    }

    func triggerLogout() {
        triggerLogoutCallCount += 1
        authData = nil
    }

    func setAuthData(_ data: AuthData?) {
        authData = data
    }
}

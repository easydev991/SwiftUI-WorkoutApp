import Foundation
import SwiftUI
import SWKeychain
import SWNetworkClient

@MainActor
final class MockAuthHelper: AuthHelperImp {
    private var mockAuthData: AuthData?

    override var authToken: String? {
        mockAuthData?.token
    }

    override init() {
        super.init()
        self.mockAuthData = AuthData(login: "mock_user", password: "mock_password")
    }

    override func saveAuthData(_ model: AuthData) {
        mockAuthData = model
    }

    override func getUserPassword() throws -> String {
        guard let password = mockAuthData?.password else {
            throw StorageError.noAuthData
        }
        return password
    }

    override func triggerLogout() {
        mockAuthData = nil
        super.triggerLogout()
    }
}

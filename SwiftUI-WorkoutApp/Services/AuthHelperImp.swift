import Combine
import Foundation
import SwiftUI
import SWKeychain
import SWNetworkClient
import SWUtils

@MainActor
class AuthHelperImp: ObservableObject, AuthHelper {
    @KeychainWrapper(Key.authData.rawValue)
    private var authData: AuthData?

    var authTokenPublisher: AnyPublisher<String?, Never> {
        $authData.map { $0?.token }.eraseToAnyPublisher()
    }

    init() {
        migrateAuthDataFromUserDefaults()
    }

    var authToken: String? { authData?.token }

    func saveAuthData(_ model: AuthData) {
        authData = model
    }

    func getUserPassword() throws -> String {
        guard let password = authData?.password else {
            throw StorageError.noAuthData
        }
        return password
    }

    func triggerLogout() {
        authData = nil
    }
}

private extension AuthHelperImp {
    enum Key: String {
        case authData
    }
}

extension AuthHelperImp {
    enum StorageError: Error, LocalizedError {
        case noAuthData

        var errorDescription: String? {
            switch self {
            case .noAuthData: "В keychain нет данных авторизации"
            }
        }
    }

    /// Старая модель, которая хранилась в `UserDefaults`
    struct LegacyAuthData: Codable {
        let password: String
        let token: String?

        var login: String? {
            guard let token else { return nil }
            guard let data = Data(base64Encoded: token),
                  let decodedString = String(data: data, encoding: .utf8)
            else { return nil }
            let components = decodedString.components(separatedBy: ":")
            guard components.count >= 2 else { return nil }
            return components[0]
        }
    }

    /// Переносит авторизационные данные из `UserDefaults` в `keychain`
    func migrateAuthDataFromUserDefaults() {
        guard authData == nil,
              let legacyData = UserDefaults.standard.data(forKey: Key.authData.rawValue)
        else { return }
        UserDefaults.standard.removeObject(forKey: Key.authData.rawValue)
        guard let oldModel = try? JSONDecoder().decode(LegacyAuthData.self, from: legacyData),
              let login = oldModel.login
        else { return }
        authData = .init(login: login, password: oldModel.password)
    }
}

import Foundation
import OSLog
import Security

final class SecureStorage {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SecureStorage.self)
    )

    enum KeychainError: Error, LocalizedError {
        case itemAlreadyExist
        case itemNotFound
        case errorStatus(String?)

        var errorDescription: String? {
            switch self {
            case .itemAlreadyExist:
                "Элемент уже существует"
            case .itemNotFound:
                "Элемент не найден"
            case let .errorStatus(message):
                message
            }
        }

        init(status: OSStatus) {
            switch status {
            case errSecDuplicateItem:
                self = .itemAlreadyExist
            case errSecItemNotFound:
                self = .itemNotFound
            default:
                let message = SecCopyErrorMessageString(status, nil) as String?
                self = .errorStatus(message)
            }
        }
    }

    func addItem(query: [CFString: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func findItem(query: [CFString: Any]) throws -> [CFString: Any]? {
        var query = query
        query[kSecReturnAttributes] = kCFBooleanTrue
        query[kSecReturnData] = kCFBooleanTrue

        var searchResult: AnyObject?

        let status = withUnsafeMutablePointer(to: &searchResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        if status != errSecSuccess {
            throw KeychainError(status: status)
        } else {
            return searchResult as? [CFString: Any]
        }
    }

    func updateItem(query: [CFString: Any], attributesToUpdate: [CFString: Any]) throws {
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func deleteItem(query: [CFString: Any]) throws {
        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }
}

extension SecureStorage {
    func addCredentials(_ credentials: AuthData, with label: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label
        query[kSecAttrAccount] = credentials.login
        query[kSecValueData] = credentials.password.data(using: .utf8)

        do {
            try addItem(query: query)
        } catch {
            logger.error("\(error.localizedDescription), label: \(label)")
            return
        }
    }

    func updateCredentials(_ credentials: AuthData, with label: String) {
        deleteCredentials(with: label)
        addCredentials(credentials, with: label)
    }

    func getCredentials(with label: String) -> AuthData? {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label

        var result: [CFString: Any]?

        do {
            result = try findItem(query: query)
        } catch {
            logger.error("\(error.localizedDescription), label: \(label)")
            return nil
        }

        if let account = result?[kSecAttrAccount] as? String,
           let data = result?[kSecValueData] as? Data,
           let password = String(data: data, encoding: .utf8) {
            return AuthData(login: account, password: password)
        } else {
            return nil
        }
    }

    func deleteCredentials(with label: String) {
        var query: [CFString: Any] = [:]
        query[kSecClass] = kSecClassGenericPassword
        query[kSecAttrLabel] = label

        do {
            try deleteItem(query: query)
        } catch {
            logger.error("\(error.localizedDescription), label: \(label)")
            return
        }
    }
}

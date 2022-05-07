//
//  Endpoint.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 02.05.2022.
//

import Foundation

enum Endpoint {
    /// Проверка входа с базовой авторизацией:
    /// **POST** ${API}/auth/login,
    case login(auth: AuthData)

    /// Восстановление пароля:
    /// **POST** ${API}/auth/reset
    case resetPassword(login: String)

    /// Получение профиля пользователя:
    /// **GET** ${API}/users/<id>
    /// `id` - идентификатор пользователя, чей профиль нужно получить
    case getUser(id: Int, auth: AuthData)

    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        request.allHTTPHeaderFields = headers
        return request
    }
}

private extension Endpoint {
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
    }

    enum HTTPHeader {
        enum Key: String {
            case authorization = "Authorization"
            case acceptEncoding = "Accept-Encoding"
        }

        enum Value: String {
            case encodingType = "gzip"
        }

        static func basicAuth(with input: AuthData) -> [String: String] {
            var headers = [String: String]()
            if let encodedString = input.base64Encoded {
                headers[Key.authorization.rawValue] = "Basic \(encodedString)"
            }
            headers[Key.acceptEncoding.rawValue] = Value.encodingType.rawValue
            return headers
        }
    }

    enum Parameter {
        enum Key: String {
            case usernameOrEmail = "username_or_email"
        }
        static func makeParameters(from params: [Key: String]) -> Data? {
            var paramsArray = [String]()
            params.forEach {
                let parameter = $0.key.rawValue + "=" + $0.value
                paramsArray.append(parameter)
            }
            let paramsString = paramsArray.joined(separator: "&")
            return paramsString.data(using: .utf8)
        }
    }

    var urlString: String {
        let baseUrl = Constants.API.baseURL
        switch self {
        case .login:
            return "\(baseUrl)/auth/login"
        case .resetPassword:
            return "\(baseUrl)/auth/reset"
        case let .getUser(id, _):
            return "\(baseUrl)/users/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .resetPassword:
            return .post
        case .getUser:
            return .get
        }
    }

    var headers: [String: String] {
        switch self {
        case let .login(auth), let .getUser(_ , auth):
            return HTTPHeader.basicAuth(with: auth)
        case .resetPassword:
            return [:]
        }
    }

    var httpBody: Data? {
        switch self {
        case .login, .getUser: return nil
        case let .resetPassword(login):
            return Parameter.makeParameters(from: [.usernameOrEmail: login])
        }
    }
}

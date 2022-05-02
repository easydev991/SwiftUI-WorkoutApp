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

    /// Получение профиля пользователя:
    /// **GET** ${API}/users/<id>
    /// `id` - идентификатор пользователя, чей профиль нужно получить
    case getUser(id: Int, auth: AuthData)

    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
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

    var urlString: String {
        switch self {
        case .login:
            return "\(Constants.API.baseURL)/auth/login"
        case let .getUser(id, _):
            return "\(Constants.API.baseURL)/users/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .getUser:
            return .get
        }
    }

    var headers: [String: String] {
        switch self {
        case let .login(auth), let .getUser(_ , auth):
            return HTTPHeader.basicAuth(with: auth)
        }
    }
}

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

    /// Изменение пароля:
    /// **POST** ${API}/auth/changepass
    case changePassword(currentPass: String, newPass: String, auth: AuthData)

    /// Получение профиля пользователя:
    /// **GET** ${API}/users/<id>
    /// `id` - идентификатор пользователя, чей профиль нужно получить
    case getUser(id: Int, auth: AuthData)

    /// Получение списка друзей:
    /// **GET** ${API}/users/<id>/friends
    /// `id` - идентификатор пользователя, чьих друзей нужно получить
    case getFriendsForUser(id: Int, auth: AuthData)

    /// Получение списка заявок на добавление в друзья:
    /// **GET** ${API}/friends/requests
    case getFriendRequests(auth: AuthData)

    /// Принять заявку на добавление в друзья:
    /// **POST** ${API}/friends/<id>/accept
    case acceptFriendRequest(friendID: Int, auth: AuthData)

    /// Получение выбранной площадки по ее номеру `id`:
    /// **GET** ${API}/areas/<id>
    case getSportsGround(id: Int, auth: AuthData)

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
            case password
            case newPassword = "new_password"
        }
        static func makeParameters(from params: [Key: String]) -> Data? {
            params
                .map { $0.key.rawValue + "=" + $0.value }
                .joined(separator: "&")
                .data(using: .utf8)
        }
    }

    var urlString: String {
        let baseUrl = Constants.API.baseURL
        switch self {
        case .login:
            return "\(baseUrl)/auth/login"
        case .resetPassword:
            return "\(baseUrl)/auth/reset"
        case .changePassword:
            return "\(baseUrl)/auth/changepass"
        case let .getUser(id, _):
            return "\(baseUrl)/users/\(id)"
        case let .getFriendsForUser(id, _):
            return "\(baseUrl)/users/\(id)/friends"
        case .getFriendRequests:
            return "\(baseUrl)/friends/requests"
        case let .acceptFriendRequest(friendID, _):
            return "\(baseUrl)/friends/\(friendID)/accept"
        case let .getSportsGround(id, _):
            return "\(baseUrl)/areas/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .resetPassword, .changePassword, .acceptFriendRequest:
            return .post
        case .getUser, .getFriendsForUser,
                .getFriendRequests, .getSportsGround:
            return .get
        }
    }

    var headers: [String: String] {
        switch self {
        case let .login(auth), let .getUser(_, auth),
            let .changePassword(_, _, auth), let .getFriendsForUser(_, auth),
            let .getFriendRequests(auth), let .acceptFriendRequest(_, auth),
            let .getSportsGround(_, auth):
            return HTTPHeader.basicAuth(with: auth)
        case .resetPassword:
            return [:]
        }
    }

    var httpBody: Data? {
        switch self {
        case .login, .getUser, .getFriendsForUser,
                .getFriendRequests, .acceptFriendRequest,
                .getSportsGround: return nil
        case let .resetPassword(login):
            return Parameter.makeParameters(from: [.usernameOrEmail: login])
        case let .changePassword(current, new, _):
            return Parameter.makeParameters(
                from: [.password: current, .newPassword: new]
            )
        }
    }
}

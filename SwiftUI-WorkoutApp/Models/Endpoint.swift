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
    case acceptFriendRequest(from: Int, auth: AuthData)

    /// Отклонить заявку на добавление в друзья:
    /// **DELETE**  ${API}/friends/<user_id>/accept
    case declineFriendRequest(from: Int, auth: AuthData)

    /// Отправить запрос на добавление в друзья:
    /// **POST**  ${API}/friends/<user_id>
    case sendFriendRequest(to: Int, auth: AuthData)

    /// Удалить из списка друзей:
    /// **DELETE**  ${API}/friends/<user_id>
    case deleteFriend(_ friendID: Int, auth: AuthData)

    /// Найти пользователей с указанным именем:
    /// **GET** ${API}/users/search?name=<user>
    case findUsers(with: String, auth: AuthData)

    /// Получение выбранной площадки по ее номеру `id`:
    /// **GET** ${API}/areas/<id>
    case getSportsGround(id: Int, auth: AuthData)

    /// Добавить комментарий для площадки:
    /// **POST** ${API}/areas/<area_id>/comments
    case addCommentToSportsGround(groundID: Int, comment: String, auth: AuthData)

    /// Изменить свой комментарий для площадки:
    /// **POST** ${API}/areas/<area_id>/comments/<comment_id>
    case editComment(groundID: Int, commentID: Int, newComment: String, auth: AuthData)

    /// Удалить свой комментарий для площадки:
    /// **DELETE** ${API}/areas/<area_id>/comments/<comment_id>
    case deleteComment(groundID: Int, commentID: Int, auth: AuthData)

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
        case delete = "DELETE"
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
            case comment
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
        case let .acceptFriendRequest(userID, _),
            let .declineFriendRequest(userID, _):
            return "\(baseUrl)/friends/\(userID)/accept"
        case let .sendFriendRequest(userID, _),
            let .deleteFriend(userID, _):
            return "\(baseUrl)/friends/\(userID)"
        case let .findUsers(name, _):
            return "\(baseUrl)/users/search?name=\(name)"
        case let .getSportsGround(id, _):
            return "\(baseUrl)/areas/\(id)"
        case let .addCommentToSportsGround(groundID, _, _):
            return "\(baseUrl)/areas/\(groundID)/comments"
        case let .editComment(groundID, commentID, _, _):
            return "\(baseUrl)/areas/\(groundID)/comments/\(commentID)"
        case let .deleteComment(groundID, commentID, _):
            return "\(baseUrl)/areas/\(groundID)/comments/\(commentID)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .resetPassword, .changePassword,
                .acceptFriendRequest, .sendFriendRequest,
                .addCommentToSportsGround, .editComment:
            return .post
        case .getUser, .getFriendsForUser,
                .getFriendRequests, .getSportsGround, .findUsers:
            return .get
        case .declineFriendRequest, .deleteFriend, .deleteComment:
            return .delete
        }
    }

    var headers: [String: String] {
        switch self {
        case let .login(auth), let .getUser(_, auth), let .changePassword(_, _, auth),
            let .getFriendsForUser(_, auth), let .getFriendRequests(auth), let .acceptFriendRequest(_, auth),
            let .declineFriendRequest(_, auth), let .sendFriendRequest(_, auth),
            let .deleteFriend(_, auth), let .getSportsGround(_, auth), let .findUsers(_, auth),
            let .addCommentToSportsGround(_, _, auth), let .editComment(_, _, _, auth),
            let .deleteComment(_, _, auth):
            return HTTPHeader.basicAuth(with: auth)
        case .resetPassword:
            return [:]
        }
    }

    var httpBody: Data? {
        switch self {
        case .login, .getUser, .getFriendsForUser, .getFriendRequests,
                .acceptFriendRequest, .declineFriendRequest, .findUsers,
                .sendFriendRequest, .deleteFriend, .getSportsGround,
                .deleteComment:
            return nil
        case let .resetPassword(login):
            return Parameter.makeParameters(from: [.usernameOrEmail: login])
        case let .changePassword(current, new, _):
            return Parameter.makeParameters(
                from: [.password: current, .newPassword: new]
            )
        case let .addCommentToSportsGround(_, comment, _), let .editComment(_, _, comment, _):
            return Parameter.makeParameters(from: [.comment: comment])
        }
    }
}

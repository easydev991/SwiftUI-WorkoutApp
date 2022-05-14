//
//  Endpoint.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 02.05.2022.
//

import Foundation

enum Endpoint {
    /// Регистрация:
    /// **POST** ${API}/registration
    case registration(form: RegistrationForm)

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

    /// Получение списка площадок, где тренируется пользователь:
    /// **GET** ${API}/users/<user_id>/areas
    case getSportsGroundsForUser(_ userID: Int, auth: AuthData)

    /// Сообщить, что пользователь тренируется на площадке:
    /// **POST** ${API}/areas/<area_id>/train
    case postTrainHere(_ groundID: Int, auth: AuthData)

    /// Сообщить, что пользователь не тренируется на площадке:
    /// **DELETE** ${API}/areas/<area_id>/train
    case deleteTrainHere(_ groundID: Int, auth: AuthData)

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
            case name, fullname, email, gender, password, comment
            case usernameOrEmail = "username_or_email"
            case newPassword = "new_password"
            case countryID = "country_id"
            case cityID = "city_id"
            case birthDate = "birth_date"
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
        case .registration:
            return "\(baseUrl)/registration"
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
        case let .getSportsGroundsForUser(userID, _):
            return "\(baseUrl)/users/\(userID)/areas"
        case let .postTrainHere(groundID, _), let .deleteTrainHere(groundID, _):
            return "\(baseUrl)/areas/\(groundID)/train"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .registration, .login, .resetPassword,
                .changePassword, .acceptFriendRequest, .sendFriendRequest,
                .addCommentToSportsGround, .editComment, .postTrainHere:
            return .post
        case .getUser, .getFriendsForUser, .getFriendRequests,
                .getSportsGround, .findUsers, .getSportsGroundsForUser:
            return .get
        case .declineFriendRequest, .deleteFriend,
                .deleteComment, .deleteTrainHere:
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
            let .deleteComment(_, _, auth), let .getSportsGroundsForUser(_, auth),
            let .postTrainHere(_, auth), let .deleteTrainHere(_, auth):
            return HTTPHeader.basicAuth(with: auth)
        case .registration, .resetPassword:
            return [:]
        }
    }

    var httpBody: Data? {
        switch self {
        case .login, .getUser, .getFriendsForUser, .getFriendRequests,
                .acceptFriendRequest, .declineFriendRequest, .findUsers,
                .sendFriendRequest, .deleteFriend, .getSportsGround,
                .deleteComment, .getSportsGroundsForUser,
                .postTrainHere, .deleteTrainHere:
            return nil
        case let .registration(form):
            return Parameter.makeParameters(
                from: [
                    .name: form.userName,
                    .fullname: form.fullName,
                    .email: form.email,
                    .password: form.password,
                    .gender: form.gender.description,
                    .countryID: form.countryID,
                    .cityID: form.cityID,
                    .birthDate: form.birthDate // "1990-11-30T21:00:00.000Z"
                ]
            )
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

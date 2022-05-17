//
//  APIService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 01.05.2022.
//

import Foundation

struct APIService {
    private let defaults: UserDefaultsService

    init(with defaults: UserDefaultsService) {
        self.defaults = defaults
    }

    /// Для запросов без базовой аутентификации
    init() {
        self.init(with: .init())
    }

    /// Выполняет регистрацию пользователя
    /// - Parameter model: необходимые для регистрации данные
    /// - Returns: Вся информация о пользователе
    func registration(with model: MainUserForm) async throws {
        let endpoint = Endpoint.registration(form: model)
        guard let request = endpoint.urlRequest else { return }
        let (data, response) = try await urlSession.data(for: request)
        let userResponse = try handle(UserResponse.self, data, response)
        await defaults.saveAuthData(.init(login: model.userName, password: model.password))
        await defaults.saveUserInfo(userResponse)
    }

    /// Запрашивает `id` пользователя для входа в учетную запись
    /// - Parameters:
    ///   - login: логин или email для входа
    ///   - password: пароль от учетной записи
    func logInWith(_ login: String, _ password: String) async throws {
        let authData = AuthData(login: login, password: password)
        let endpoint = Endpoint.login(auth: authData)
        guard let request = endpoint.urlRequest else { return }
        let (data, response) = try await urlSession.data(for: request)
        let loginResponse = try handle(LoginResponse.self, data, response)
        await defaults.saveAuthData(authData)
        try await getUserByID(loginResponse.userID, loginFlow: true)
    }

    /// Запрашивает данные пользователя по `id`, сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameter userID: `id` пользователя
    /// - Returns: Вся информация о пользователе
    @discardableResult
    func getUserByID(_ userID: Int, loginFlow: Bool = false) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return .emptyValue }
        let (data, response) = try await urlSession.data(for: request)
        let userInfo = try handle(UserResponse.self, data, response)
        if loginFlow {
            await defaults.saveUserInfo(userInfo)
        }
        return userInfo
    }

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        guard let request = endpoint.urlRequest else { return false }
        let (data, response) = try await urlSession.data(for: request)
        let userIdResponse = try handle(LoginResponse.self, data, response)
        return userIdResponse.userID != .zero
    }

    /// Изменяет данные пользователя
    /// - Parameters:
    ///   - id: `id` пользователя
    ///   - model: данные для изменения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editUser(_ id: Int, model: MainUserForm) async throws -> Bool {
        let authData = defaults.basicAuthInfo
        let endpoint = Endpoint.editUser(id: id, form: model, auth: authData)
        guard let request = endpoint.urlRequest else { return false }
        let (data, response) = try await urlSession.data(for: request)
        let userResponse = try handle(UserResponse.self, data, response)
        await defaults.saveAuthData(.init(login: model.userName, password: authData.password))
        await defaults.saveUserInfo(userResponse)
        return userResponse.userName == model.userName
    }

    /// Меняет текущий пароль на новый, в случае успеха сохраняет новый пароль в `defaults`
    /// - Parameters:
    ///   - current: текущий пароль
    ///   - new: новый пароль
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func changePassword(current: String, new: String) async throws -> Bool {
        let authData = defaults.basicAuthInfo
        let endpoint = Endpoint.changePassword(
            currentPass: current, newPass: new, auth: authData
        )
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
        let isSuccess = try handle(response)
        if isSuccess {
            await defaults.saveAuthData(.init(login: authData.login, password: new))
        }
        return isSuccess
    }

    /// Загружает список друзей для выбранного пользователя; для главного пользователя в случае успеха сохраняет идентификаторы друзей в `defaults`
    /// - Parameter id: `id` пользователя
    /// - Returns: Список друзей выбранного пользователя
    @discardableResult
    func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendsForUser(id: id, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return [] }
        let (data, response) = try await urlSession.data(for: request)
        let friends = try handle([UserResponse].self, data, response)
        if id == defaults.mainUserID {
            await defaults.saveFriendsIds(friends.compactMap(\.userID))
        }
        return friends
    }

    /// Загружает список заявок на добавление в друзья, в случае успеха - сохраняет в `defaults`
    func getFriendRequests() async throws {
        let endpoint = Endpoint.getFriendRequests(auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return }
        let (data, response) = try await urlSession.data(for: request)
        let result = try handle([UserResponse].self, data, response)
        await defaults.saveFriendRequests(result)
    }

    /// Отвечает на заявку для добавления в друзья, и в случае успеха запрашивает список заявок повторно, а если запрос одобрен - дополнительно запрашивает список друзей
    /// - Parameters:
    ///   - userID: `id` инициатора заявки
    ///   - accept: `true` - одобрить заявку, `false` - отклонить
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func respondToFriendRequest(from userID: Int, accept: Bool) async throws -> Bool {
        let endpoint: Endpoint = accept
        ? .acceptFriendRequest(from: userID, auth: defaults.basicAuthInfo)
        : .declineFriendRequest(from: userID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
        let isSuccess = try handle(response)
        if isSuccess {
            if accept {
                try await getFriendsForUser(id: defaults.mainUserID)
            }
            try await getFriendRequests()
        }
        return isSuccess
    }

    /// Совершает действие со статусом друга/пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя, к которому применяется действие
    ///   - option: вид действия - отправить заявку на добавление в друзья или удалить из списка друзей
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func friendAction(userID: Int, option: Constants.FriendAction) async throws -> Bool {
        let endpoint: Endpoint = option == .sendFriendRequest
        ? .sendFriendRequest(to: userID, auth: defaults.basicAuthInfo)
        : .deleteFriend(userID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
        let isSuccess = try handle(response)
        if isSuccess && option == .removeFriend {
            if option == .removeFriend {
                try await getFriendsForUser(id: defaults.mainUserID)
            }
        }
        return isSuccess
    }

    /// Ищет пользователей, чей логин содержит указанный текст
    /// - Parameter name: текст для поиска
    /// - Returns: Список пользователей, чей логин содержит указанный текст
    func findUsers(with name: String) async throws -> [UserResponse] {
        let endpoint = Endpoint.findUsers(with: name, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return [] }
        let (data, response) = try await urlSession.data(for: request)
        return try handle([UserResponse].self, data, response)
    }

    /// Загружает данные по отдельной площадке
    /// - Parameter id: `id` площадки
    /// - Returns: Вся информация о площадке
    func getSportsGround(id: Int) async throws -> SportsGround {
        let endpoint = Endpoint.getSportsGround(id: id, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return .emptyValue }
        let (data, response) = try await urlSession.data(for: request)
        return try handle(SportsGround.self, data, response)
    }

    /// Добавить комментарий для площадки
    /// - Parameters:
    ///   - groundID: `id` площадки
    ///   - comment: текст комментария
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func addComment(to groundID: Int, comment: String) async throws -> Bool {
        let endpoint = Endpoint.addCommentToSportsGround(groundID: groundID, comment: comment, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
        return try handle(response)
    }

    /// Изменить свой комментарий для площадки
    /// - Parameters:
    ///   - groundID: `id` площадки
    ///   - commentID: `id` комментария
    ///   - newComment: текст измененного комментария
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editComment(for groundID: Int, commentID: Int, newComment: String) async throws -> Bool {
        let endpoint = Endpoint.editComment(
            groundID: groundID,
            commentID: commentID,
            newComment: newComment,
            auth: defaults.basicAuthInfo
        )
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
        return try handle(response)
    }

    /// Удалить комментарий для площадки
    /// - Parameters:
    ///   - groundID: `id` площадки
    ///   - commentID: `id` комментария
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func deleteComment(from groundID: Int, commentID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteComment(groundID: groundID, commentID: commentID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
        return try handle(response)
    }

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userID: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    func getSportsGroundsForUser(_ userID: Int) async throws -> [SportsGround] {
        let endpoint = Endpoint.getSportsGroundsForUser(userID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return [] }
        let (data, response) = try await urlSession.data(for: request)
        return try handle([SportsGround].self, data, response)
    }

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - groundID: `id` площадки
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    func changeTrainHereStatus(for groundID: Int, trainHere: Bool) async throws -> Bool {
        let endpoint: Endpoint = trainHere
        ? .postTrainHere(groundID, auth: defaults.basicAuthInfo)
        : .deleteTrainHere(groundID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return false }
        let (_, response) = try await urlSession.data(for: request)
#warning("TODO: интеграция с БД")
        return try handle(response)
    }

    /// Запрашивает список событий
    /// - Parameter type: тип события (предстоящее или прошедшее)
    /// - Returns: Список событий
    func getEvents(of type: EventType) async throws -> [EventResponse] {
        let endpoint: Endpoint = type == .future
        ? .getFutureEvents
        : .getPastEvents
        guard let request = endpoint.urlRequest else { return [] }
        let (data, response) = try await urlSession.data(for: request)
        return try handle([EventResponse].self, data, response)
    }

    /// Запрашивает конкретное событие
    /// - Parameter id: `id` события
    /// - Returns: Вся информация по событию
    func getEvent(by id: Int) async throws -> EventResponse {
        let endpoint = Endpoint.getEvent(id: id)
        guard let request = endpoint.urlRequest else { return .emptyValue }
        let (data, response) = try await urlSession.data(for: request)
        return try handle(EventResponse.self, data, response)
    }
}

private extension APIService {
    var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.timeOut
        config.timeoutIntervalForResource = Constants.API.timeOut
        config.waitsForConnectivity = true
        return .init(configuration: config)
    }

    /// Обрабатывает ответ сервера и возвращает данные в нужном формате
    func handle<T: Decodable>(
        _ type: T.Type,
        _ data: Data?,
        _ response: URLResponse?
    ) throws -> T {
        guard let data = data, !data.isEmpty else {
            throw APIError.noData
        }
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != Constants.API.codeOK {
            throw handleError(from: data, with: responseCode)
        }
#if DEBUG
        print("--- Получили ответ:")
        dump(response)
        print("--- Полученный JSON:\n\(data.prettyJson)")
        do {
            try JSONDecoder().decode(type, from: data)
        } catch {
            print("--- error: \(error)")
            fatalError(error.localizedDescription)
        }
#endif
        let decodedInfo = try JSONDecoder().decode(type, from: data)
#if DEBUG
        print("--- Преобразованные данные:\n\(decodedInfo)")
#endif
        return decodedInfo
    }

    /// Обрабатывает ответ сервера, в котором важен только статус
    func handle(_ response: URLResponse?) throws -> Bool {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != Constants.API.codeOK {
            throw APIError(with: responseCode)
        }
#if DEBUG
        print("--- Получили ответ:")
        dump(response)
#endif
        return responseCode == Constants.API.codeOK
    }

    /// Обрабатывает ошибки
    /// - Parameters:
    ///   - data: данные для обработки
    ///   - code: код ответа
    /// - Returns: Готовая к выводу ошибка `APIError`
    func handleError(from data: Data, with code: Int?) -> APIError {
        print("--- JSON с ошибкой:")
        print(data.prettyJson)
        if let errorInfo = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return APIError(errorInfo)
        } else {
            return APIError(with: code)
        }
    }
}
// MARK: - Endpoint
private extension APIService {
    enum Endpoint {
        /// Регистрация:
        /// **POST** ${API}/registration
        case registration(form: MainUserForm)

        /// Проверка входа с базовой авторизацией:
        /// **POST** ${API}/auth/login,
        case login(auth: AuthData)

        /// Восстановление пароля:
        /// **POST** ${API}/auth/reset
        case resetPassword(login: String)

        /// Изменить данные пользователя:
        /// **POST** ${API}/users/<user_id>
        case editUser(id: Int, form: MainUserForm, auth: AuthData)

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

        /// Получить список предстоящих событий:
        /// **GET** ${API}/trainings/current
        case getFutureEvents

        /// Получить краткий список прошедших событий:
        /// **GET** ${API}/trainings/last
        case getPastEvents

        /// Получить информацию о конкретном событии:
        /// **GET** ${API}/trainings/<event_id>
        case getEvent(id: Int)

        var urlRequest: URLRequest? {
            guard let url = URL(string: urlString) else { return nil }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = httpBody
            request.allHTTPHeaderFields = headers
            return request
        }

        private var urlString: String {
            let baseUrl = Constants.API.baseURL
            switch self {
            case .registration:
                return "\(baseUrl)/registration"
            case .login:
                return "\(baseUrl)/auth/login"
            case .resetPassword:
                return "\(baseUrl)/auth/reset"
            case let .editUser(userID, _, _):
                return "\(baseUrl)/users/\(userID)"
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
            case .getFutureEvents:
                return "\(baseUrl)/trainings/current"
            case .getPastEvents:
                return "\(baseUrl)/trainings/last"
            case let .getEvent(id):
                return "\(baseUrl)/trainings/\(id)"
            }
        }

        private var method: HTTPMethod {
            switch self {
            case .registration, .login, .editUser, .resetPassword,
                    .changePassword, .acceptFriendRequest, .sendFriendRequest,
                    .addCommentToSportsGround, .editComment, .postTrainHere:
                return .post
            case .getUser, .getFriendsForUser, .getFriendRequests,
                    .getSportsGround, .findUsers, .getSportsGroundsForUser,
                    .getFutureEvents, .getPastEvents, .getEvent:
                return .get
            case .declineFriendRequest, .deleteFriend,
                    .deleteComment, .deleteTrainHere:
                return .delete
            }
        }

        private var headers: [String: String] {
            switch self {
            case let .login(auth), let .getUser(_, auth), let .editUser(_, _, auth),
                let .changePassword(_, _, auth), let .getFriendsForUser(_, auth),
                let .getFriendRequests(auth), let .acceptFriendRequest(_, auth),
                let .declineFriendRequest(_, auth), let .sendFriendRequest(_, auth),
                let .deleteFriend(_, auth), let .getSportsGround(_, auth), let .findUsers(_, auth),
                let .addCommentToSportsGround(_, _, auth), let .editComment(_, _, _, auth),
                let .deleteComment(_, _, auth), let .getSportsGroundsForUser(_, auth),
                let .postTrainHere(_, auth), let .deleteTrainHere(_, auth):
                return HTTPHeader.basicAuth(with: auth)
            case .registration, .resetPassword, .getFutureEvents,
                    .getPastEvents, .getEvent:
                return [:]
            }
        }

        private var httpBody: Data? {
            switch self {
            case .login, .getUser, .getFriendsForUser, .getFriendRequests,
                    .acceptFriendRequest, .declineFriendRequest, .findUsers,
                    .sendFriendRequest, .deleteFriend, .getSportsGround,
                    .deleteComment, .getSportsGroundsForUser,
                    .postTrainHere, .deleteTrainHere,
                    .getFutureEvents, .getPastEvents, .getEvent:
                return nil
            case let .registration(form):
                return Parameter.makeParameters(
                    from: [
                        .name: form.userName,
                        .fullname: form.fullName,
                        .email: form.email,
                        .password: form.password,
                        .genderCode: form.genderCode.description,
                        .countryID: form.country.id,
                        .cityID: form.city.id,
                        .birthDate: form.birthDateIsoString
                    ]
                )
            case let .editUser(_, form, _):
                return Parameter.makeParameters(
                    from: [
                        .name: form.userName,
                        .fullname: form.fullName,
                        .email: form.email,
                        .genderCode: form.genderCode.description,
                        .countryID: form.country.id,
                        .cityID: form.city.id,
                        .birthDate: form.birthDateIsoString
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

        enum HTTPMethod: String {
            case get = "GET"
            case post = "POST"
            case delete = "DELETE"
        }

        enum HTTPHeader {
            enum Key: String {
                case authorization = "Authorization"
                case acceptEncoding = "Accept-Encoding"
            }

            enum Value: String { case encodingType = "gzip" }

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
                case name, fullname, email, password, comment
                case genderCode = "gender"
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
    }
}
// MARK: - APIError
private extension APIService {
    enum APIError: Error, LocalizedError {
        case noData
        case noResponse
        case badRequest
        case invalidCredentials
        case notFound
        case serverError
        case customError(String)

        init(_ error: ErrorResponse) {
            if let message = error.message, error.realCode != 401 {
                self = .customError(message)
            } else if let array = error.errors {
                let message = array.joined(separator: ",\n")
                self = .customError(message)
            } else {
                self.init(with: error.realCode)
            }
        }

        init(with code: Int?) {
            switch code {
            case 400: self = .badRequest
            case 401: self = .invalidCredentials
            case 404: self = .notFound
            case 500: self = .serverError
            default: self = .noResponse
            }
        }

        var errorDescription: String? {
            switch self {
            case .noData:
                return "Сервер не прислал данные для обработки ответа"
            case .noResponse:
                return "Сервер не отвечает"
            case .badRequest:
                return "Запрос содержит ошибку"
            case .invalidCredentials:
                return "Некорректное имя пользователя или пароль"
            case .notFound:
                return "Запрашиваемый ресурс не найден"
            case .serverError:
                return "Внутренняя ошибка сервера"
            case let .customError(error):
                return error
            }
        }
    }
}

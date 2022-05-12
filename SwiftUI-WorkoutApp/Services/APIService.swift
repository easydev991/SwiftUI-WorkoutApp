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

    /// Запрашивает `id` пользователя для входа в учетную запись
    /// - Parameters:
    ///   - login: логин или email для входа
    ///   - password: пароль от учетной записи
    func logInWith(_ login: String, _ password: String) async throws {
        let authData = AuthData(login: login, password: password)
        let endpoint = Endpoint.login(auth: authData)
        guard let request = endpoint.urlRequest else { return }
        let (data, response) = try await urlSession.data(for: request)
        let loginResponse = try handle(UserIdResponse.self, data, response)
        await MainActor.run {
            defaults.setMainUserID(loginResponse.userID)
            defaults.saveAuthData(authData)
        }
        try await getUserByID(loginResponse.userID)
    }

    /// Запрашивает данные пользователя по `id`, сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameter userID: `id` пользователя
    /// - Returns: Вся информация о пользователе
    @discardableResult
    func getUserByID(_ userID: Int) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userID, auth: defaults.basicAuthInfo)
        guard let request = endpoint.urlRequest else { return .emptyValue }
        let (data, response) = try await urlSession.data(for: request)
        let userInfo = try handle(UserResponse.self, data, response)
        if userID == defaults.mainUserID {
            await MainActor.run {
                defaults.saveUserInfo(userInfo)
                if !defaults.isAuthorized { defaults.setUserLoggedIn() }
            }
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
        let userIdResponse = try handle(UserIdResponse.self, data, response)
        return userIdResponse.userID != .zero
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
            await MainActor.run {
                defaults.saveFriendsIds(friends.compactMap(\.userID))
            }
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
                defaults.needUpdateUser = true
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
            defaults.needUpdateUser = true
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
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != Constants.API.codeOK, let error = APIError(with: responseCode) {
            throw error
        }
        guard let data = data, !data.isEmpty else {
            throw APIError.noData
        }
        print("--- Получили ответ:")
        dump(response)
        let prettyString = String(data: data, encoding: .utf8)
        print("--- Полученный JSON:\n\(prettyString.valueOrEmpty)")
        let decodedInfo = try JSONDecoder().decode(type, from: data)
        print("--- Преобразованные данные:\n\(decodedInfo)")
        return decodedInfo
    }

    /// Обрабатывает ответ сервера, в котором важен только статус
    func handle(_ response: URLResponse?) throws -> Bool {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != Constants.API.codeOK, let error = APIError(with: responseCode) {
            throw error
        }
        print("--- Получили ответ:")
        dump(response)
        return responseCode == Constants.API.codeOK
    }
}

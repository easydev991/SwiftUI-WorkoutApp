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
        try await getUserByID(loginResponse.userID, loginFlow: true)
    }

    /// Запрашивает данные пользователя по `id`
    /// - Parameter userID: `id` пользователя
    /// - Returns: Вся информация о пользователе
    @discardableResult
    func getUserByID(_ userID: Int, loginFlow: Bool = false) async throws -> UserResponse? {
        let endpoint = Endpoint.getUser(id: userID, auth: defaults.getAuthData())
        guard let request = endpoint.urlRequest else { return nil }
        let (data, response) = try await urlSession.data(for: request)
        let userInfo = try handle(UserResponse.self, data, response)
        if loginFlow && userID == defaults.mainUserID {
            await MainActor.run {
                defaults.saveUserInfo(userInfo)
                defaults.setUserLoggedIn()
            }
        }
        return userInfo
    }

    func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        guard let request = endpoint.urlRequest else { return false }
        let (data, response) = try await urlSession.data(for: request)
        let userIdResponse = try handle(UserIdResponse.self, data, response)
        return userIdResponse.userID != .zero
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

    /// Обрабатывает ответ сервера
    func handle<T: Decodable>(
        _ type: T.Type,
        _ data: Data?,
        _ response: URLResponse?
    ) throws -> T {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != 200, let error = APIError(with: responseCode) {
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
}

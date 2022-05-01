//
//  APIService.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 01.05.2022.
//

import Foundation

struct APIService {
    static func handleResponse<T: Decodable>(
        _ type: T.Type,
        data: Data?,
        response: URLResponse?
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
        let prettyString = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "")
        print("--- Полученный JSON:\n\(prettyString.valueOrEmpty)")
        do {
            let decodedInfo = try JSONDecoder().decode(type, from: data)
            print("--- Преобразованные данные:\n\(decodedInfo)")
            return decodedInfo
        } catch {
            throw error
        }
    }

    static func configuredURLSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.timeOut
        config.timeoutIntervalForResource = Constants.API.timeOut
        config.waitsForConnectivity = true
        return .init(configuration: config)
    }
}

enum APIError: Error, LocalizedError {
    case noData
    case noResponse
    case badRequest
    case invalidCredentials
    case notFound
    case serverError

    init?(with code: Int?) {
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
        }
    }
}

struct AuthData {
    let login, password: String
}

enum Endpoint {
    /// Проверка входа с базовой авторизацией:
    /// **POST** ${API}/auth/login,
    case login(auth: AuthData)

    /// Получение профиля пользователя:
    /// **GET** ${API}/users/<id>
    /// `id` - идентификатор пользователя, чей профиль нужно получить
    case getUser(id: Int, auth: AuthData)

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
            return HTTPHeader.basicAuth(login: auth.login, password: auth.password)
        }
    }

    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
}

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
        case encodingTypes = "gzip"
    }

    static func basicAuth(login: String, password: String) -> [String: String] {
        var headers = [String: String]()
        if let authData = (login + ":" + password).data(using: .utf8)?.base64EncodedString() {
            headers[Key.authorization.rawValue] = "Basic \(authData)"
        }
        headers[Key.acceptEncoding.rawValue] = Value.encodingTypes.rawValue
        return headers
    }
}

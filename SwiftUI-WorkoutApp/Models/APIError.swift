//
//  APIError.swift
//  SwiftUI-WorkoutApp
//
//  Created by Олег Еременко on 02.05.2022.
//

import Foundation

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

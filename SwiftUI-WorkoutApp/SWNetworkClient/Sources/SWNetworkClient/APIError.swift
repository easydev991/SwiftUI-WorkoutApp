import Foundation
import SWModels

extension SWClient {
    enum APIError: Error, LocalizedError {
        case noData
        case noResponse
        case badRequest
        case invalidCredentials
        case notFound
        case payloadTooLarge
        case serverError
        case invalidUserID
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
            case 413: self = .payloadTooLarge
            case 500: self = .serverError
            default: self = .noResponse
            }
        }

        var errorDescription: String? {
            switch self {
            case .noData:
                "Сервер не прислал данные для обработки ответа"
            case .noResponse:
                "Сервер не отвечает"
            case .badRequest:
                "Запрос содержит ошибку"
            case .invalidCredentials:
                "Некорректное имя пользователя или пароль"
            case .notFound:
                "Запрашиваемый ресурс не найден"
            case .payloadTooLarge:
                "Объем данных для загрузки на сервер превышает лимит"
            case .serverError:
                "Внутренняя ошибка сервера"
            case .invalidUserID:
                "Некорректный идентификатор пользователя"
            case let .customError(error):
                error
            }
        }
    }
}

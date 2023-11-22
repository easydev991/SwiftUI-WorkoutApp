import Foundation
import SWModels

extension SWClient {
    enum APIError: Error, LocalizedError {
        case noData
        case unknown
        case badRequest
        case invalidCredentials
        case notFound
        case payloadTooLarge
        case serverError
        case invalidUserID
        case customError(code: Int, message: String)

        init(_ error: ErrorResponse, _ code: Int?) {
            if code == 401 {
                self = .invalidCredentials
            } else if let message = error.message {
                self = .customError(code: code ?? 404, message: message)
            } else if let array = error.errors {
                let message = array.joined(separator: ",\n")
                self = .customError(code: code ?? 404, message: message)
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
            default: self = .unknown
            }
        }

        var errorDescription: String? {
            switch self {
            case .noData:
                "Сервер не прислал данные для обработки ответа"
            case .unknown:
                "Неизвестная ошибка"
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
            case let .customError(code, error):
                "\(code), \(error)"
            }
        }
    }
}

import Foundation

public enum APIError: Error, LocalizedError, Equatable {
    case noData
    case unknown
    case badRequest
    case invalidCredentials
    case notFound
    case payloadTooLarge
    case serverError
    case invalidUserID
    case customError(code: Int, message: String)
    case decodingError
    case notConnectedToInternet

    init(_ error: ErrorResponse, _ statusCode: Int?) {
        let serverCode = error.makeRealCode(statusCode: statusCode)

        // Приоритет 1: Кастомные сообщения из ErrorResponse
        if let message = error.realMessage {
            self = .customError(
                code: serverCode,
                message: message.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            return
        }

        // Приоритет 2: Обработка через код (если есть валидный код)
        if serverCode != 0 {
            self.init(with: serverCode)
            return
        }

        // Приоритет 3: Стандартный код из статуса
        if let statusCode {
            self.init(with: statusCode)
            return
        }

        // Если все варианты исчерпаны
        self = .unknown
    }

    init(with code: Int?) {
        guard let code else {
            self = .unknown
            return
        }
        switch code {
        case 400, 402, 403, 405 ... 412, 414 ... 499: self = .badRequest
        case 401: self = .invalidCredentials
        case 404: self = .notFound
        case 413: self = .payloadTooLarge
        case 500 ... 599: self = .serverError
        default: self = .unknown
        }
    }

    public var errorDescription: String? {
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
        case .decodingError:
            "Не удалось декодировать ответ"
        case .notConnectedToInternet:
            "Нет соединения с сетью"
        }
    }
}

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
            NSLocalizedString("Error.NoData", bundle: .module, comment: "Сервер не прислал данные для обработки ответа")
        case .unknown:
            NSLocalizedString("Error.Unknown", bundle: .module, comment: "Неизвестная ошибка")
        case .badRequest:
            NSLocalizedString("Error.BadRequest", bundle: .module, comment: "Запрос содержит ошибку")
        case .invalidCredentials:
            NSLocalizedString("Error.InvalidCredentials", bundle: .module, comment: "Некорректное имя пользователя или пароль")
        case .notFound:
            NSLocalizedString("Error.NotFound", bundle: .module, comment: "Запрашиваемый ресурс не найден")
        case .payloadTooLarge:
            NSLocalizedString("Error.PayloadTooLarge", bundle: .module, comment: "Объем данных для загрузки на сервер превышает лимит")
        case .serverError:
            NSLocalizedString("Error.ServerError", bundle: .module, comment: "Внутренняя ошибка сервера")
        case .invalidUserID:
            NSLocalizedString("Error.InvalidUserID", bundle: .module, comment: "Некорректный идентификатор пользователя")
        case let .customError(code, error):
            "\(code), \(error)"
        case .decodingError:
            NSLocalizedString("Error.Decoding", bundle: .module, comment: "Не удалось декодировать ответ")
        case .notConnectedToInternet:
            NSLocalizedString("Error.NoInternet", bundle: .module, comment: "Нет соединения с сетью")
        }
    }
}

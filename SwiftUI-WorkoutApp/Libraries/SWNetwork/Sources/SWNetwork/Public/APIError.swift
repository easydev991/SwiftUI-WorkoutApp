import Foundation

public enum APIError: Error, LocalizedError, Equatable {
    case unknown
    case badRequest
    case invalidCredentials
    case notFound
    case payloadTooLarge
    case serverError
    case invalidUserId
    case customError(code: Int, message: String)
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
        case .unknown:
            String(localized: .errorUnknown)
        case .badRequest:
            String(localized: .errorBadRequest)
        case .invalidCredentials:
            String(localized: .errorInvalidCredentials)
        case .notFound:
            String(localized: .errorNotFound)
        case .payloadTooLarge:
            String(localized: .errorPayloadTooLarge)
        case .serverError:
            String(localized: .errorServerError)
        case .invalidUserId:
            String(localized: .errorInvalidUserID)
        case let .customError(code, error):
            "\(code), \(error)"
        case .notConnectedToInternet:
            String(localized: .errorNoInternet)
        }
    }
}

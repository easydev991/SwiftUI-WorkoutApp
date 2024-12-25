import Foundation
import OSLog

/// Сервис для отправки запросов и обработки ответов сервера по адресу `https://workout.su/api/v3`
public struct SWNetworkService: Sendable {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SWNetwork", category: "SWNetworkService")
    private let successCode: Int
    private let forceLogoutCode: Int
    /// Время таймаута для `URLSession`
    private let timeoutInterval: TimeInterval
    /// `true` - нужна базовая аутентификация, `false` - не нужна
    ///
    /// Базовая аутентификация не нужна в приложении "SW: Площадки" для запросов:
    /// - `getUpdatedParks`
    /// - `registration`
    /// - `resetPassword`
    private let needAuth: Bool
    private var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval
        return .init(configuration: config)
    }

    /// `true` - дебаг-события будут логироваться в консоли, `false` - не будут
    private let enableDebugLogs: Bool

    /// Инициализатор
    /// - Parameters:
    ///   - successCode: Код успешного ответа, по умолчанию `200`
    ///   - forceLogoutCode: Код принудительного логаута, по умолчанию `401`
    ///   - timeoutInterval: Время ожидания ответа сервера, по умолчанию `30` (сек.)
    ///   - needAuth: Нужна ли аутентификация, по умолчанию `true`
    ///   - enableDebugLogs: Нужно ли логировать дебаг-события в консоли. Ошибки будут логироваться всегда.
    public init(
        successCode: Int = 200,
        forceLogoutCode: Int = 401,
        timeoutInterval: TimeInterval = 30,
        needAuth: Bool = true,
        enableDebugLogs: Bool = true
    ) {
        self.successCode = successCode
        self.forceLogoutCode = forceLogoutCode
        self.timeoutInterval = timeoutInterval
        self.needAuth = needAuth
        self.enableDebugLogs = enableDebugLogs
    }

    /// Загружает данные в нужном формате или отдает ошибку
    /// - Parameters:
    ///   - type: тип, который нужно загрузить
    ///   - request: запрос, по которому нужно обратиться
    ///   - encodedString: `base64Encoded`-строка с "токеном" для авторизованного пользователя
    /// - Returns: Вся информация по запрошенному типу
    public func makeResult<T: Decodable>(
        _ type: T.Type,
        for request: URLRequest?,
        encodedString: String?
    ) async throws -> T {
        guard let request = finalRequest(request, encodedString) else {
            let apiError = APIError.badRequest
            logger.error(
                """
                \(apiError.localizedDescription, privacy: .public)
                \nURL запроса: \(request?.url?.absoluteString ?? "-", privacy: .public)
                """
            )
            throw apiError
        }
        let (data, response) = try await urlSession.data(for: request)
        return try await handle(type, data, response)
    }

    /// Выполняет действие, не требующее указания типа
    /// - Parameter request: запрос, по которому нужно обратиться
    /// - Returns: Статус действия
    public func makeStatus(
        for request: URLRequest?,
        encodedString: String?
    ) async throws -> Bool {
        guard let request = finalRequest(request, encodedString) else {
            let apiError = APIError.badRequest
            logger.error(
                """
                \(apiError.localizedDescription, privacy: .public)
                \nURL запроса: \(request?.url?.absoluteString ?? "-", privacy: .public)
                """
            )
            throw apiError
        }
        let response = try await urlSession.data(for: request).1
        return try await handle(response)
    }

    /// Формирует итоговый запрос к серверу
    /// - Parameters:
    ///   - request: первоначальный запрос
    ///   - encodedString: `base64Encoded`-строка с "токеном" для авторизованного пользователя
    /// - Returns: Итоговый запрос к серверу
    private func finalRequest(_ request: URLRequest?, _ encodedString: String?) -> URLRequest? {
        if needAuth, let encodedString {
            var requestWithBasicAuth = request
            requestWithBasicAuth?.setValue(
                "Basic \(encodedString)",
                forHTTPHeaderField: "Authorization"
            )
            return requestWithBasicAuth
        } else {
            return request
        }
    }

    /// Обрабатывает ответ сервера и возвращает данные в нужном формате
    private func handle<T: Decodable>(_ type: T.Type, _ data: Data?, _ response: URLResponse?) async throws -> T {
        let urlString = response?.url?.absoluteString ?? "-"
        guard let data, !data.isEmpty else {
            let apiError = APIError.noData
            logger.error(
                """
                \(apiError.localizedDescription, privacy: .public)
                \nURL запроса: \(urlString, privacy: .public)
                """
            )
            throw apiError
        }
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        guard responseCode == successCode else {
            throw handleError(from: data, response: response)
        }
        do {
            if enableDebugLogs {
                logger.debug(
                    """
                    Обработали ответ сервера
                    \nURL запроса: \(urlString, privacy: .public)
                    \nJSON в ответе: \(data.prettyJson, privacy: .public)
                    """
                )
            }
            return try JSONDecoder().decode(type, from: data)
        } catch {
            logger.error(
                """
                Ошибка декодирования: \(error.localizedDescription, privacy: .public)
                \nURL запроса: \(urlString, privacy: .public)
                \nJSON в ответе: \(data.prettyJson, privacy: .public)
                """
            )
            throw error
        }
    }

    /// Обрабатывает ответ сервера, в котором важен только статус
    private func handle(_ response: URLResponse?) async throws -> Bool {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        let urlString = response?.url?.absoluteString ?? "-"
        if enableDebugLogs {
            logger.debug(
                """
                Обработали ответ сервера
                \nURL запроса: \(urlString, privacy: .public)
                \nСтатус в ответе: \(responseCode ?? 0, privacy: .public)
                """
            )
        }
        guard responseCode == successCode else {
            let apiError = APIError(with: responseCode)
            logger.error(
                """
                Ошибка обработки ответа сервера: \(apiError.localizedDescription, privacy: .public)
                \nURL запроса: \(urlString, privacy: .public)
                \nСтатус в ответе: \(responseCode ?? 0, privacy: .public)
                """
            )
            throw apiError
        }
        return true
    }

    /// Обрабатывает ошибки
    /// - Parameters:
    ///   - data: данные об ошибке
    ///   - response: ответ сервера
    /// - Returns: Готовая к выводу ошибка `APIError`
    private func handleError(from data: Data, response: URLResponse?) -> APIError {
        let errorCode = (response as? HTTPURLResponse)?.statusCode
        guard errorCode != forceLogoutCode else {
            return .invalidCredentials
        }
        let urlString = response?.url?.absoluteString ?? "-"
        do {
            let errorInfo = try JSONDecoder().decode(ErrorResponse.self, from: data)
            let apiError = APIError(errorInfo, errorCode)
            if enableDebugLogs {
                logger.debug(
                    """
                    Обработали ошибку в ответе
                    \nКод ошибки: \(errorCode ?? 0, privacy: .public)
                    \nURL запроса: \(urlString, privacy: .public)
                    \nJSON с ошибкой: \(data.prettyJson, privacy: .public)
                    \nПреобразованная ошибка: \(apiError.localizedDescription, privacy: .public)
                    """
                )
            }
            return apiError
        } catch {
            let apiError = APIError(with: errorCode)
            logger.error(
                """
                Ошибка декодирования: \(error.localizedDescription, privacy: .public)
                \nURL запроса: \(urlString, privacy: .public)
                \nJSON с ошибкой: \(data.prettyJson, privacy: .public)
                \nПреобразованная ошибка: \(apiError.localizedDescription, privacy: .public)
                """
            )
            return apiError
        }
    }
}

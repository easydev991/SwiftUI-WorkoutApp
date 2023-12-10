import Foundation
import SWModels

extension SWClient {
    private var successCode: Int { 200 }
    private var forceLogoutCode: Int { 401 }

    var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval
        return .init(configuration: config)
    }

    /// Загружает данные в нужном формате или отдает ошибку
    /// - Parameters:
    ///   - type: тип, который нужно загрузить
    ///   - request: запрос, по которому нужно обратиться
    /// - Returns: Вся информация по запрошенному типу
    func makeResult<T: Decodable>(_ type: T.Type, for request: URLRequest?) async throws -> T {
        guard let request = await finalRequest(request) else {
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
    func makeStatus(for request: URLRequest?) async throws -> Bool {
        guard let request = await finalRequest(request) else {
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
    /// - Parameter request: первоначальный запрос
    /// - Returns: Итоговый запрос к серверу
    func finalRequest(_ request: URLRequest?) async -> URLRequest? {
        if needAuth,
           let encodedString = try? await defaults.basicAuthInfo().base64Encoded {
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
    func handle<T: Decodable>(_ type: T.Type, _ data: Data?, _ response: URLResponse?) async throws -> T {
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
            if canForceLogout, responseCode == forceLogoutCode {
                await defaults.triggerLogout()
            }
            throw handleError(from: data, response: response)
        }
        do {
            logger.debug(
                """
                Обработали ответ сервера
                \nURL запроса: \(urlString, privacy: .public)
                \nJSON в ответе: \(data.prettyJson, privacy: .public)
                """
            )
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
    func handle(_ response: URLResponse?) async throws -> Bool {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        let urlString = response?.url?.absoluteString ?? "-"
        logger.debug(
            """
            Обработали ответ сервера
            \nURL запроса: \(urlString, privacy: .public)
            \nСтатус в ответе: \(responseCode ?? 0, privacy: .public)
            """
        )
        guard responseCode == successCode else {
            if canForceLogout, responseCode == forceLogoutCode {
                await defaults.triggerLogout()
            }
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
    func handleError(from data: Data, response: URLResponse?) -> APIError {
        let errorCode = (response as? HTTPURLResponse)?.statusCode
        let urlString = response?.url?.absoluteString ?? "-"
        do {
            let errorInfo = try JSONDecoder().decode(ErrorResponse.self, from: data)
            let apiError = APIError(errorInfo, errorCode)
            logger.debug(
                """
                Обработали ошибку в ответе
                \nКод ошибки: \(errorCode ?? 0, privacy: .public)
                \nURL запроса: \(urlString, privacy: .public)
                \nJSON с ошибкой: \(data.prettyJson, privacy: .public)
                \nПреобразованная ошибка: \(apiError.localizedDescription, privacy: .public)
                """
            )
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

import Foundation
import OSLog
import SWModels

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SWClient")

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
        guard let request = await finalRequest(request) else { throw APIError.badRequest }
        let (data, response) = try await urlSession.data(for: request)
        return try await handle(type, data, response)
    }

    /// Выполняет действие, не требующее указания типа
    /// - Parameter request: запрос, по которому нужно обратиться
    /// - Returns: Статус действия
    func makeStatus(for request: URLRequest?) async throws -> Bool {
        guard let request = await finalRequest(request) else {
            throw APIError.badRequest
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
        guard let data, !data.isEmpty else {
            throw APIError.noData
        }
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        guard responseCode == successCode else {
            if canForceLogout, responseCode == forceLogoutCode {
                await defaults.triggerLogout()
            }
            throw handleError(from: data, response: response)
        }
        #if DEBUG
        let urlString = response?.url?.absoluteString ?? "unknown"
        logger.info("✅ Получили JSON по запросу: \(urlString)")
        logger.debug("\(data.prettyJson)")
        do {
            _ = try JSONDecoder().decode(type, from: data)
        } catch {
            logger.error("⛔️ Ошибка декодирования: \(error)")
        }
        #endif
        return try JSONDecoder().decode(type, from: data)
    }

    /// Обрабатывает ответ сервера, в котором важен только статус
    func handle(_ response: URLResponse?) async throws -> Bool {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        #if DEBUG
        let urlString = response?.url?.absoluteString ?? "unknown"
        logger.info("✅ Получили статус \(responseCode ?? 0) по запросу: \(urlString)")
        #endif
        guard responseCode == successCode else {
            if canForceLogout, responseCode == forceLogoutCode {
                await defaults.triggerLogout()
            }
            throw APIError(with: responseCode)
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
        #if DEBUG
        let errorCodeMessage = if let errorCode {
            "Код ошибки \(errorCode)"
        } else {
            "Ошибка!"
        }
        let urlString = response?.url?.absoluteString ?? "unknown"
        logger.error("⛔️ \(errorCodeMessage)\nJSON с ошибкой по запросу: \(urlString)")
        logger.debug("\(data.prettyJson)")
        #endif
        if let errorInfo = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return APIError(errorInfo, errorCode)
        } else {
            return APIError(with: errorCode)
        }
    }
}

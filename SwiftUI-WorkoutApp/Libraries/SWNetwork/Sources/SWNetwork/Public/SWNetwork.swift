import Foundation
import OSLog

public protocol NetworkServicing: Sendable {
    func requestData<T: Decodable>(components: RequestComponents) async throws -> T
    func requestStatus(components: RequestComponents) async throws
}

public struct SWNetworkService: NetworkServicing {
    /// Единственная сессия на приложение: все операции переиспользуют пул
    /// TCP/TLS-соединений и HTTP/2-мультиплексирование (план fix-api-timeout-1001, шаг 4)
    private static let sharedSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration)
    }()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "SWNetworkService",
        category: String(describing: SWNetworkService.self)
    )
    private let decoder = JSONDecoder()

    public init() {}
}

public extension SWNetworkService {
    func requestData<T: Decodable>(components: RequestComponents) async throws -> T {
        guard let request = components.urlRequest else {
            throw APIError.badRequest
        }
        do {
            let (data, response) = try await make(request)
            guard let response else {
                throw logUnknownError(request: request, data: data)
            }
            do {
                switch StatusCodeGroup(code: response.statusCode) {
                case .success:
                    let decodedResult = try decoder.decode(T.self, from: data)
                    logSuccess(request: request, data: data)
                    return decodedResult
                default:
                    let errorInfo = try decoder.decode(ErrorResponse.self, from: data)
                    throw log(
                        APIError(errorInfo, response.statusCode),
                        request: request,
                        data: data,
                        response: response
                    )
                }
            } catch {
                throw log(error, request: request, data: data, response: response)
            }
        } catch {
            throw handleUrlSession(error, request)
        }
    }

    func requestStatus(components: RequestComponents) async throws {
        guard let request = components.urlRequest else {
            throw APIError.badRequest
        }
        do {
            let (data, response) = try await make(request)
            guard let response else {
                throw logUnknownError(request: request, data: data)
            }
            if StatusCodeGroup(code: response.statusCode).isSuccess {
                logSuccess(request: request, data: data)
                return
            }
            do {
                let errorInfo = try decoder.decode(ErrorResponse.self, from: data)
                throw log(
                    APIError(errorInfo, response.statusCode),
                    request: request,
                    data: data,
                    response: response
                )
            } catch {
                throw log(error, request: request, data: data, response: response)
            }
        } catch {
            throw handleUrlSession(error, request)
        }
    }
}

private extension SWNetworkService {
    /// Делает запрос с проверкой на ошибку авторизации (код 401)
    func make(_ request: URLRequest) async throws -> (Data, HTTPURLResponse?) {
        let (data, response) = try await Self.sharedSession.data(for: request)
        let httpURLResponse = response as? HTTPURLResponse
        if let statusCode = httpURLResponse?.statusCode,
           statusCode != 400,
           StatusCodeGroup(code: statusCode).isError {
            if statusCode == 401 {
                throw APIError.invalidCredentials
            }
            // 404 различаем по телу: настоящий API-404 против HTML-страницы nginx-прокси
            if statusCode == 404 {
                throw isApiNotFoundBody(data) ? APIError.notFound : APIError.serverUnavailable
            }
            throw APIError(with: statusCode)
        }
        return (data, httpURLResponse)
    }

    /// Логирует успешный ответ
    func logSuccess(request: URLRequest, data: Data) {
        logger.info(
            """
            Получили успешный ответ сервера
            \nURL запроса: \(request.urlString, privacy: .public)
            \nJSON в ответе: \(data.prettyJson, privacy: .public)
            """
        )
    }

    func logUnknownError(request: URLRequest, data: Data) -> Error {
        let error = APIError.unknown
        logger.error(
            """
            \(error.localizedDescription, privacy: .public)
            \nURL запроса: \(request.urlString, privacy: .public)
            \nJSON в ответе: \(data.prettyJson, privacy: .public)
            """
        )
        return error
    }

    func log(
        _ error: Error,
        request: URLRequest,
        data: Data,
        response: HTTPURLResponse
    ) -> Error {
        logger.error(
            """
            Код ответа: \(response.statusCode, privacy: .public)
            \(error.localizedDescription, privacy: .public)
            \nURL запроса: \(request.urlString, privacy: .public)
            \nответ (response): \(response)
            \nJSON в ответе: \(data.prettyJson, privacy: .public)
            """
        )
        return error
    }
}

extension SWNetworkService {
    /// Обрабатывает ошибку `URLSession`
    ///
    /// В дебаг/стейдж сборках логирует ошибку
    /// - Parameters:
    ///   - error: Исходная ошибка
    ///   - request: Запрос, упавший в ошибку
    /// - Returns: Новая ошибка
    func handleUrlSession(_ error: Error, _ request: URLRequest) -> Error {
        let errorCode = (error as NSError).code
        guard errorCode != -999 else {
            let message = "Запрос отменён! Код ошибки: -999. URL запроса: \(request.urlString)"
            logger.error("\(message)")
            return CancellationError()
        }
        logger.error(
            """
            Ошибка!
            \(error.localizedDescription, privacy: .public)
            Код ошибки: \(errorCode, privacy: .public)
            \nURL запроса: \(request.urlString, privacy: .public)
            """
        )
        guard let urlError = error as? URLError else {
            return error
        }
        switch urlError.code {
        case .notConnectedToInternet, .dataNotAllowed:
            return APIError.notConnectedToInternet
        case .timedOut:
            return APIError.timedOut
        default:
            return error
        }
    }
}

private extension URLRequest {
    var urlString: String {
        url?.absoluteString ?? ""
    }
}

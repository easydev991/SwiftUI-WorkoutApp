import Foundation
import OSLog

public protocol SWNetworkProtocol: Sendable {
    /// Делает запрос и возвращает данные в ответе
    func requestData<T: Decodable>(components: RequestComponents) async throws -> T
    /// Делает запрос и возвращает `true/false` в ответе
    func requestStatus(components: RequestComponents) async throws -> Bool
}

public struct SWNetworkService {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "SWNetworkService",
        category: String(describing: SWNetworkService.self)
    )
    private let session: URLSession
    private let decoder = JSONDecoder()

    public init(
        timeoutIntervalForRequest: Double = 30,
        timeoutIntervalForResource: Double = 60
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = timeoutIntervalForResource
        self.session = URLSession(configuration: configuration)
    }
}

extension SWNetworkService: SWNetworkProtocol {
    public func requestData<T: Decodable>(components: RequestComponents) async throws -> T {
        guard let request = components.urlRequest else {
            throw APIError.badRequest
        }
        do {
            let (data, response) = try await make(request)
            guard let response else {
                throw logUnknownError(request: request, data: data)
            }
            switch StatusCodeGroup(code: response.statusCode) {
            case .success:
                guard let decodedResult = try? decoder.decode(T.self, from: data) else {
                    throw log(
                        APIError.decodingError,
                        code: response.statusCode,
                        request: request,
                        data: data,
                        response: response
                    )
                }
                logSuccess(request: request, data: data)
                return decodedResult
            default:
                let errorInfo = try decoder.decode(ErrorResponse.self, from: data)
                let apiError = APIError(errorInfo, response.statusCode)
                throw log(
                    apiError,
                    code: response.statusCode,
                    request: request,
                    data: data,
                    response: response
                )
            }
        } catch {
            throw handleUrlSession(error, request)
        }
    }

    public func requestStatus(components: RequestComponents) async throws -> Bool {
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
                return true
            }
            if let errorInfo = try? decoder.decode(ErrorResponse.self, from: data) {
                let apiError = APIError(errorInfo, response.statusCode)
                log(
                    apiError,
                    code: response.statusCode,
                    request: request,
                    data: data,
                    response: response
                )
                throw apiError
            }
            return false
        } catch {
            throw handleUrlSession(error, request)
        }
    }
}

private extension SWNetworkService {
    /// Делает запрос с проверкой на ошибку авторизации (код 401)
    func make(_ request: URLRequest) async throws -> (Data, HTTPURLResponse?) {
        let (data, response) = try await session.data(for: request)
        let httpURLResponse = response as? HTTPURLResponse
        if let statusCode = httpURLResponse?.statusCode,
           statusCode != 400,
           StatusCodeGroup(code: statusCode).isError {
            throw statusCode == 401
                ? APIError.invalidCredentials
                : APIError(with: statusCode)
        }
        return (data, httpURLResponse)
    }

    /// Логирует успешный ответ
    func logSuccess(request: URLRequest, data: Data) {
        logger.info(
            """
            Обработали ответ сервера
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

    @discardableResult
    func log(
        _ error: Error,
        code: Int,
        request: URLRequest,
        data: Data,
        response _: HTTPURLResponse?
    ) -> Error {
        logger.error(
            """
            Код ответа: \(code, privacy: .public)
            \(error.localizedDescription, privacy: .public)
            \nURL запроса: \(request.urlString, privacy: .public)
            \nJSON в ответе: \(data.prettyJson, privacy: .public)
            """
        )
        return error
    }

    /// Обрабатывает ошибку `URLSession`
    ///
    /// В дебаг/стейдж сборках логирует ошибку
    /// - Parameters:
    ///   - error: Исходная ошибка
    ///   - request: Запрос, упавший в ошибку
    /// - Returns: Новая ошибка
    @discardableResult
    func handleUrlSession(_ error: Error, _ request: URLRequest) -> Error {
        logger.error(
            """
            \(error.localizedDescription, privacy: .public)
            \nURL запроса: \(request.urlString, privacy: .public)
            """
        )
        guard let urlError = error as? URLError else {
            return error
        }
        switch urlError.code {
        case .notConnectedToInternet, .dataNotAllowed:
            return APIError.notConnectedToInternet
        default:
            return error
        }
    }
}

private extension URLRequest {
    var urlString: String { url?.absoluteString ?? "" }
}

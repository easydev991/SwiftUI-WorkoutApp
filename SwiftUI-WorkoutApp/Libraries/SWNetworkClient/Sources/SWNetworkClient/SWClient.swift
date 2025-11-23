import Foundation
import OSLog
import SWModels
import SWNetwork

/// Сервис для обращений к серверу
public struct SWClient: Sendable {
    let authHelper: AuthHelper
    /// Сервис для отправки запросов/получения ответов от сервера
    let service: SWNetworkProtocol

    /// Инициализатор
    /// - Parameter authHelper: Сервис, предоставляющий токен авторизации,
    /// и выполняющий логаут при необходимости
    public init(with authHelper: AuthHelper) {
        self.authHelper = authHelper
        self.service = SWNetworkService()
    }
}

// MARK: - Обертки для SWNetworkService

extension SWClient {
    func makeStatus(for endpoint: Endpoint) async throws {
        do {
            let finalComponents = try await makeComponents(for: endpoint)
            try await service.requestStatus(components: finalComponents)
        } catch APIError.invalidCredentials {
            await authHelper.triggerLogout()
            throw ClientError.forceLogout
        } catch APIError.notConnectedToInternet {
            throw ClientError.noConnection
        } catch APIError.notFound {
            throw ClientError.notFound
        } catch {
            throw error
        }
    }

    func makeResult<T: Decodable>(
        for endpoint: Endpoint,
        with token: String? = nil
    ) async throws -> T {
        do {
            let finalComponents = try await makeComponents(for: endpoint, with: token)
            return try await service.requestData(components: finalComponents)
        } catch APIError.invalidCredentials {
            await authHelper.triggerLogout()
            throw ClientError.forceLogout
        } catch APIError.notConnectedToInternet {
            throw ClientError.noConnection
        } catch APIError.notFound {
            throw ClientError.notFound
        } catch {
            throw error
        }
    }

    func makeComponents(
        for endpoint: Endpoint,
        with token: String? = nil
    ) async throws -> RequestComponents {
        let savedToken = await authHelper.authToken
        return .init(
            path: endpoint.urlPath,
            queryItems: endpoint.queryItems,
            httpMethod: endpoint.method,
            hasMultipartFormData: endpoint.hasMultipartFormData,
            bodyParts: endpoint.bodyParts,
            token: token ?? savedToken
        )
    }
}

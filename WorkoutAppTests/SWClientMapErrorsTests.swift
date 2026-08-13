import Foundation
import SWNetwork
@testable import SWNetworkClient
import Testing

@Suite("SWClient.mapErrors — маппинг APIError в ClientError")
@MainActor
struct SWClientMapErrorsTests {
    struct MapErrorsCase {
        let apiError: APIError
        let expectedClientError: ClientError?
        let expectedLogoutCallCount: Int
    }

    @Test("Должен мапить APIError в ClientError и дёргать triggerLogout только на 401", arguments: [
        MapErrorsCase(apiError: .invalidCredentials, expectedClientError: .forceLogout, expectedLogoutCallCount: 1),
        MapErrorsCase(apiError: .notFound, expectedClientError: .notFound, expectedLogoutCallCount: 0),
        MapErrorsCase(apiError: .notConnectedToInternet, expectedClientError: .noConnection, expectedLogoutCallCount: 0),
        MapErrorsCase(apiError: .unknown, expectedClientError: nil, expectedLogoutCallCount: 0)
    ])
    func mapErrors(testCase: MapErrorsCase) async throws {
        let authHelper = MockAuthHelperForDefaultsService()
        let mockService = MockSWNetworkService()
        mockService.errorToThrow = testCase.apiError
        let client = SWClient(with: authHelper, service: mockService)

        if let expected = testCase.expectedClientError {
            await #expect(throws: expected) {
                _ = try await client.makeStatus(for: .login)
            }
        } else {
            await #expect(throws: testCase.apiError) {
                _ = try await client.makeStatus(for: .login)
            }
        }

        #expect(authHelper.triggerLogoutCallCount == testCase.expectedLogoutCallCount)
    }

    @Test("Должен считать каждый вызов triggerLogout независимо при повторных 401")
    func repeatedInvalidCredentialsCountsEachLogout() async throws {
        let authHelper = MockAuthHelperForDefaultsService()
        let mockService = MockSWNetworkService()
        mockService.errorToThrow = APIError.invalidCredentials
        let client = SWClient(with: authHelper, service: mockService)

        await #expect(throws: ClientError.forceLogout) {
            _ = try await client.makeStatus(for: .login)
        }
        await #expect(throws: ClientError.forceLogout) {
            _ = try await client.makeStatus(for: .login)
        }

        #expect(authHelper.triggerLogoutCallCount == 2)
    }
}

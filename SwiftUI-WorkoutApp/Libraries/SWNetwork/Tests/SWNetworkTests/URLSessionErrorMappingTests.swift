import Foundation
@testable import SWNetwork
import Testing

struct URLSessionErrorMappingTests {
    @Test("URLError.timedOut маппится в APIError.timedOut")
    func timedOutMapsToTimedOutCase() throws {
        let service = SWNetworkService()
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))

        let result = service.handleUrlSession(URLError(.timedOut), request)

        #expect(result as? APIError == .timedOut)
    }

    @Test("Нет маппинга для неизвестных кодов URLError — возвращается исходная ошибка")
    func unknownUrlErrorIsNotMapped() throws {
        let service = SWNetworkService()
        let request = try URLRequest(url: #require(URL(string: "https://example.com")))

        let result = service.handleUrlSession(URLError(.cannotFindHost), request)

        #expect(result is URLError)
    }
}

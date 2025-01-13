import Foundation
@testable import SWNetwork
import Testing

struct RequestComponentsTests {
    @Test
    func initialization() {
        let path = "/test"
        let queryItems = [URLQueryItem(name: "key", value: "value")]
        let httpMethod = HTTPMethod.get
        let headerFields = [HTTPHeaderField(key: "Authorization", value: "Bearer token")]
        let body = Data("test body".utf8)
        let needAuth = true
        let requestComponents = RequestComponents(
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod,
            headerFields: headerFields,
            body: body,
            needAuth: needAuth
        )
        #expect(requestComponents.path == path)
        #expect(requestComponents.queryItems == queryItems)
        #expect(requestComponents.httpMethod == httpMethod)
        #expect(requestComponents.headerFields == headerFields)
        #expect(requestComponents.body == body)
        #expect(requestComponents.needAuth == needAuth)
    }

    @Test
    func urlGeneration() throws {
        let requestComponents = RequestComponents(
            path: "/test",
            queryItems: [URLQueryItem(name: "key", value: "value")],
            httpMethod: .get
        )
        let resultURL = try #require(requestComponents.url)
        let expectedURLString = "https://workout.su/api/v3/test?key=value"
        #expect(resultURL.absoluteString == expectedURLString)
    }

    @Test
    func urlRequestCreation() throws {
        let path = "/test"
        let queryItems = [URLQueryItem(name: "key", value: "value")]
        let httpMethod = HTTPMethod.post
        let headerFields = [HTTPHeaderField(key: "Authorization", value: "Bearer token")]
        let body = Data("test body".utf8)
        let requestComponents = RequestComponents(
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod,
            headerFields: headerFields,
            body: body
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let expectedHeaderFields = Dictionary(uniqueKeysWithValues: headerFields.map { ($0.key, $0.value) })
        #expect(urlRequest.httpMethod == httpMethod.rawValue)
        #expect(urlRequest.httpBody == body)
        #expect(urlRequest.allHTTPHeaderFields == expectedHeaderFields)
    }
}

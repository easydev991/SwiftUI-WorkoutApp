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
        let token = "token"
        let requestComponents = RequestComponents(
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod,
            headerFields: headerFields,
            body: body,
            token: token
        )
        #expect(requestComponents.path == path)
        #expect(requestComponents.queryItems == queryItems)
        #expect(requestComponents.httpMethod == httpMethod)
        #expect(requestComponents.headerFields == headerFields)
        #expect(requestComponents.body == body)
        #expect(requestComponents.token == token)
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
    func urlRequestCreationWithAuthToken() throws {
        let path = "/test"
        let queryItems = [URLQueryItem(name: "key", value: "value")]
        let httpMethod = HTTPMethod.post
        let headerFields = [HTTPHeaderField(key: "key", value: "value")]
        let body = Data("test body".utf8)
        let token = "token123"
        let requestComponents = RequestComponents(
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod,
            headerFields: headerFields,
            body: body,
            token: token
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let expectedHeaderFields: [HTTPHeaderField] = [
            .init(key: "key", value: "value"),
            .init(key: "Authorization", value: "Basic token123")
        ]
        let finalHeaderFields = try #require(urlRequest.allHTTPHeaderFields)
        #expect(urlRequest.httpMethod == httpMethod.rawValue)
        #expect(urlRequest.httpBody == body)
        #expect(finalHeaderFields.count == expectedHeaderFields.count)
        #expect(
            expectedHeaderFields.allSatisfy { header in
                finalHeaderFields[header.key] == header.value
            }
        )
    }

    @Test
    func urlRequestCreationWithoutAuthToken() throws {
        let path = "/test"
        let queryItems = [URLQueryItem(name: "key", value: "value")]
        let httpMethod = HTTPMethod.post
        let headerFields = [HTTPHeaderField(key: "key", value: "value")]
        let body = Data("test body".utf8)
        let requestComponents = RequestComponents(
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod,
            headerFields: headerFields,
            body: body
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let expectedHeaderFields = ["key": "value"]
        let finalHeaderFields = try #require(urlRequest.allHTTPHeaderFields)
        #expect(urlRequest.httpMethod == httpMethod.rawValue)
        #expect(urlRequest.httpBody == body)
        #expect(finalHeaderFields == expectedHeaderFields)
    }
}

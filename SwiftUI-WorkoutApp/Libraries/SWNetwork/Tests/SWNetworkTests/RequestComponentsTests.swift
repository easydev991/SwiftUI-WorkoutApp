import Foundation
@testable import SWNetwork
import Testing

struct RequestComponentsTests {
    @Test
    func initialization() {
        let path = "/test"
        let queryItems = [URLQueryItem(name: "key", value: "value")]
        let httpMethod = HTTPMethod.get
        let body = Data("test body".utf8)
        let token = "token"
        let requestComponents = RequestComponents(
            path: path,
            queryItems: queryItems,
            httpMethod: httpMethod,
            body: body,
            token: token
        )
        #expect(requestComponents.path == path)
        #expect(requestComponents.queryItems == queryItems)
        #expect(requestComponents.httpMethod == httpMethod)
        #expect(requestComponents.body == body)
        #expect(requestComponents.token == token)
    }

    @Test(arguments: [HTTPMethod.put, .get, .post, .delete])
    func urlRequestCreationWithSpecificMethod(_ method: HTTPMethod) throws {
        let requestComponents = RequestComponents(
            path: "/test",
            httpMethod: method
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        #expect(urlRequest.httpMethod == method.rawValue)
    }

    @Test("Генерация URL без ведущего слеша в path")
    func urlCreationFailure() {
        let requestComponents = RequestComponents(
            path: "invalidpath",
            httpMethod: .get
        )
        #expect(requestComponents.url == nil)
    }

    @Test
    func urlRequestCreationWithEmptyToken() throws {
        let requestComponents = RequestComponents(
            path: "/test",
            httpMethod: .get,
            token: ""
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let headers = try #require(urlRequest.allHTTPHeaderFields)
        #expect(headers["Authorization"] == nil)
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
        let body = Data("test body".utf8)
        let requestComponents = RequestComponents(
            path: "/test",
            httpMethod: .post,
            body: body,
            token: "token123"
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let headers = try #require(urlRequest.allHTTPHeaderFields)
        #expect(urlRequest.httpBody == body)
        #expect(headers.count == 2)
        #expect(headers["Content-Length"] == "\(body.count)")
        #expect(headers["Authorization"] == "Basic token123")
    }

    @Test
    func urlRequestCreationWithoutAuthToken() throws {
        let body = Data("test body".utf8)
        let requestComponents = RequestComponents(
            path: "/test",
            httpMethod: .post,
            body: body
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let headerFields = try #require(urlRequest.allHTTPHeaderFields)
        #expect(urlRequest.httpBody == body)
        #expect(headerFields == ["Content-Length": "\(body.count)"])
    }

    @Test
    func urlRequestCreationWithoutBody() throws {
        let requestComponents = RequestComponents(
            path: "/test",
            httpMethod: .get,
            body: nil,
            token: "token"
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let headers = try #require(urlRequest.allHTTPHeaderFields)
        #expect(headers.count == 1)
        #expect(headers["Content-Length"] == nil)
        #expect(headers["Authorization"] == "Basic token")
    }

    @Test
    func urlRequestCreationWithMultipartFormData() throws {
        let body = Data("test".utf8)
        let requestComponents = RequestComponents(
            path: "/upload",
            httpMethod: .post,
            hasMultipartFormData: true,
            body: body,
            token: "token"
        )
        let urlRequest = try #require(requestComponents.urlRequest)
        let headers = try #require(urlRequest.allHTTPHeaderFields)
        #expect(headers.count == 3)
        #expect(headers["Content-Type"] == "multipart/form-data; boundary=FFF")
        #expect(headers["Content-Length"] == "\(body.count)")
        #expect(headers["Authorization"] == "Basic token")
    }

    @Test
    func urlGenerationWithSpecialCharacters() throws {
        let requestComponents = RequestComponents(
            path: "/test path",
            queryItems: [URLQueryItem(name: "key", value: "value with space")],
            httpMethod: .get
        )
        let resultURL = try #require(requestComponents.url)
        let expectedString = "https://workout.su/api/v3/test%20path?key=value%20with%20space"
        #expect(resultURL.absoluteString == expectedString)
    }
}

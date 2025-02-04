import Foundation
@testable import SWNetwork
import Testing

struct RequestComponentsTests {
    // MARK: - URL

    @Test
    func urlConstructionWithValidPath() throws {
        let components = RequestComponents(
            path: "/test",
            httpMethod: .get,
            boundary: "TEST"
        )
        let url = try #require(components.url)
        #expect(url.absoluteString == "https://workout.su/api/v3/test")
    }

    @Test
    func urlConstructionWithInvalidPath() {
        let components = RequestComponents(
            path: "invalid",
            httpMethod: .get
        )
        #expect(components.url == nil)
    }

    @Test
    func urlWithQueryItems() throws {
        let components = RequestComponents(
            path: "/search",
            queryItems: [URLQueryItem(name: "q", value: "test")],
            httpMethod: .get
        )
        let url = try #require(components.url)
        let query = try #require(url.query)
        #expect(query == "q=test")
    }

    // MARK: - Настройка URLRequest

    @Test
    func basicRequestConfiguration() throws {
        let components = RequestComponents(
            path: "/test",
            httpMethod: .post,
            boundary: "TEST"
        )
        let request = try #require(components.urlRequest)
        let httpMethod = try #require(request.httpMethod)
        #expect(httpMethod == "POST")
        let urlString = try #require(request.url?.absoluteString)
        #expect(urlString == "https://workout.su/api/v3/test")
    }

    // MARK: - Хедеры и тело

    @Test
    func multipartFormDataHeaders() throws {
        let components = RequestComponents(
            path: "/upload",
            httpMethod: .post,
            hasMultipartFormData: true,
            bodyParts: .init(["text": "value"], nil),
            boundary: "BOUNDARY123"
        )
        let request = try #require(components.urlRequest)
        let headers = try #require(request.allHTTPHeaderFields)
        let contentType = try #require(headers["Content-Type"])
        #expect(contentType == "multipart/form-data; boundary=BOUNDARY123")
        let bodyData = try #require(request.httpBody)
        let contentLength = try #require(headers["Content-Length"])
        #expect(contentLength == "\(bodyData.count)")
    }

    @Test
    func authorizationHeader() throws {
        let components = RequestComponents(
            path: "/secure",
            httpMethod: .get,
            token: "secret_token"
        )
        let headers = try #require(components.urlRequest?.allHTTPHeaderFields)
        let authHeader = try #require(headers["Authorization"])
        #expect(authHeader == "Basic secret_token")
    }

    @Test
    func urlEncodedBody() throws {
        let params = ["name": "John", "age": "30"]
        let components = RequestComponents(
            path: "/form",
            httpMethod: .post,
            bodyParts: .init(params, nil)
        )
        let request = try #require(components.urlRequest)
        let bodyData = try #require(request.httpBody)
        let bodyString = try #require(String(data: bodyData, encoding: .utf8))
        let sortedBodyString = bodyString.components(separatedBy: "&").sorted().joined(separator: "&")
        #expect(sortedBodyString == "age=30&name=John")
    }

    @Test
    func multipartBodyContent() throws {
        let media = BodyMaker.MediaFile(
            key: "file",
            filename: "test.txt",
            data: Data("content".utf8),
            mimeType: "text/plain"
        )
        let components = RequestComponents(
            path: "/upload",
            httpMethod: .post,
            hasMultipartFormData: true,
            bodyParts: .init(["title": "Doc"], [media]),
            boundary: "TESTBOUNDARY"
        )
        let request = try #require(components.urlRequest)
        let bodyData = try #require(request.httpBody)
        let bodyString = try #require(String(data: bodyData, encoding: .utf8))

        let expectedPatterns = [
            "--TESTBOUNDARY\r\n",
            "Content-Disposition: form-data; name=\"title\"\r\n\r\nDoc\r\n",
            "Content-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\n",
            "Content-Type: text/plain\r\n\r\ncontent\r\n",
            "--TESTBOUNDARY--\r\n"
        ]

        for pattern in expectedPatterns {
            #expect(bodyString.contains(pattern))
        }
    }

    // MARK: - Едж-кейсы

    @Test
    func emptyRequestComponents() throws {
        let components = RequestComponents(
            path: "/",
            httpMethod: .get
        )
        let request = try #require(components.urlRequest)
        #expect(request.url?.absoluteString == "https://workout.su/api/v3/")
    }

    @Test
    func invalidTokenHandling() throws {
        let components = RequestComponents(
            path: "/secure",
            httpMethod: .get,
            token: ""
        )
        let headers = try #require(components.urlRequest?.allHTTPHeaderFields)
        #expect(!headers.keys.contains("Authorization"))
    }

    @Test
    func missingBodyHandling() throws {
        let components = RequestComponents(
            path: "/empty",
            httpMethod: .post
        )
        let request = try #require(components.urlRequest)
        #expect(request.httpBody == nil)
    }

    @Test
    func urlWithEncodedQueryItems() throws {
        let components = RequestComponents(
            path: "/search",
            queryItems: [URLQueryItem(name: "q", value: "test&value")],
            httpMethod: .get
        )
        let query = try #require(components.url?.query)
        // Проверка кодировки амперсанда
        #expect(query == "q=test%26value")
    }

    @Test
    func emptyParameterValueHandling() throws {
        let components = RequestComponents(
            path: "/form",
            httpMethod: .post,
            bodyParts: .init(["empty": ""], nil)
        )
        let request = try #require(components.urlRequest)
        let bodyString = try #require(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        #expect(bodyString == "empty=")
    }

    @Test
    func largeDataHandling() throws {
        // 10 MB данных
        let bigData = Data(repeating: 0x55, count: 10_000_000)
        let media = BodyMaker.MediaFile(
            key: "bigfile",
            filename: "large.bin",
            data: bigData,
            mimeType: "application/octet-stream"
        )

        let components = RequestComponents(
            path: "/upload",
            httpMethod: .post,
            hasMultipartFormData: true,
            bodyParts: .init([:], [media]),
            boundary: "BIGBOUNDARY"
        )

        let request = try #require(components.urlRequest)
        let contentLength = try #require(request.allHTTPHeaderFields?["Content-Length"])
        let expectedSize = request.httpBody?.count ?? 0
        #expect(contentLength == "\(expectedSize)")
    }
}

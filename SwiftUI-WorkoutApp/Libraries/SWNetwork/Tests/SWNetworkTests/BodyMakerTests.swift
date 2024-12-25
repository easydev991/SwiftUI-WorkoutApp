import Foundation
@testable import SWNetwork
import Testing

struct BodyMakerTests {
    private typealias Parameter = BodyMaker.Parameter

    @Test
    func makeBody_noParameters() {
        let parameters = [Parameter<TestKey>]()
        let result = BodyMaker.makeBody(with: parameters)
        #expect(result == nil)
    }

    @Test
    func makeBody_validParameters() throws {
        let parameters: [Parameter<TestKey>] = [
            .init(key: TestKey.name.rawValue, value: "John"),
            .init(key: TestKey.age.rawValue, value: "30")
        ]
        let expectedData = try #require("name=John&age=30".data(using: .utf8))
        let result = try #require(BodyMaker.makeBody(with: parameters))
        #expect(result == expectedData)
    }

    @Test
    func makeBodyWithMultipartForm_noParameters_noMedia() {
        let parameters = [Parameter<TestKey>]()
        let result = BodyMaker.makeBodyWithMultipartForm(with: parameters, and: nil)
        #expect(result == nil)
    }

    @Test
    func makeBodyWithMultipartForm_onlyDictionary() throws {
        let parameters: [Parameter<TestKey>] = [
            .init(key: TestKey.name.rawValue, value: "John"),
            .init(key: TestKey.age.rawValue, value: "30")
        ]
        let expectedData = try #require(
            "--FFF\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\nJohn\r\n--FFF\r\nContent-Disposition: form-data; name=\"age\"\r\n\r\n30\r\n--FFF--\r\n"
                .data(using: .utf8)
        )
        let result = try #require(BodyMaker.makeBodyWithMultipartForm(with: parameters, and: nil))
        #expect(result == expectedData)
    }

    @Test
    func makeBodyWithMultipartForm_onlyMedia() throws {
        let parameters = [Parameter<TestKey>]()
        let mediaFile = BodyMaker.MediaFile(
            key: "file",
            filename: "test.png",
            data: Data("Test image content".utf8),
            mimeType: "image/png"
        )
        let expectedData = try #require(
            "--FFF\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.png\"\r\nContent-Type: image/png\r\n\r\nTest image content\r\n--FFF--\r\n"
                .data(using: .utf8)
        )
        let result = try #require(BodyMaker.makeBodyWithMultipartForm(with: parameters, and: [mediaFile]))
        #expect(result == expectedData)
    }

    @Test
    func makeBodyWithMultipartForm_dictionaryAndMedia() throws {
        let parameters: [Parameter<TestKey>] = [.init(key: TestKey.description.rawValue, value: "A test image")]
        let mediaFile = BodyMaker.MediaFile(
            key: "file",
            filename: "test.png",
            data: Data("Test image content".utf8),
            mimeType: "image/png"
        )
        let expectedData = try #require(
            "--FFF\r\nContent-Disposition: form-data; name=\"description\"\r\n\r\nA test image\r\n--FFF\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.png\"\r\nContent-Type: image/png\r\n\r\nTest image content\r\n--FFF--\r\n"
                .data(using: .utf8)
        )
        let result = try #require(BodyMaker.makeBodyWithMultipartForm(with: parameters, and: [mediaFile]))
        #expect(result == expectedData)
    }
}

/// Пример ключа для тестирования
private enum TestKey: String {
    case name
    case age
    case description
}

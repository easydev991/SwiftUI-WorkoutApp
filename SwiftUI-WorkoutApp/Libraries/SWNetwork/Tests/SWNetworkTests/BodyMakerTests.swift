import Foundation
@testable import SWNetwork
import Testing

struct BodyMakerTests {
    @Test
    func parameterInitializationFromDictionaryElement() {
        let element = ("testKey", "testValue")
        let parameter = BodyMaker.Parameter(from: element)
        #expect(parameter.key == "testKey")
        #expect(parameter.value == "testValue")
    }

    // MARK: - makeBody

    @Test
    func makeBodyWithNoParametersReturnsNil() {
        let result = BodyMaker.makeBody(with: [])
        #expect(result == nil)
    }

    @Test
    func makeBodyWithSingleParameter() throws {
        let parameter = BodyMaker.Parameter(key: "name", value: "John")
        let result = try #require(BodyMaker.makeBody(with: [parameter]))
        let expectedString = "name=John"
        #expect(String(data: result, encoding: .utf8) == expectedString)
    }

    @Test
    func makeBodyWithMultipleParameters() throws {
        let params = [
            BodyMaker.Parameter(key: "a", value: "1"),
            BodyMaker.Parameter(key: "b", value: "2")
        ]
        let result = try #require(BodyMaker.makeBody(with: params))
        let expectedString = "a=1&b=2"
        #expect(String(data: result, encoding: .utf8) == expectedString)
    }

    // MARK: - makeBodyWithMultipartForm

    @Test
    func multipartFormWithNoContentReturnsNil() {
        let result = BodyMaker.makeBodyWithMultipartForm(
            parameters: [],
            media: nil,
            boundary: "BOUNDARY"
        )
        #expect(result == nil)
    }

    @Test
    func multipartFormWithParametersOnly() throws {
        let params = [BodyMaker.Parameter(key: "text", value: "Hello")]
        let boundary = "TESTBOUNDARY"
        let result = try #require(BodyMaker.makeBodyWithMultipartForm(
            parameters: params,
            media: nil,
            boundary: boundary
        ))
        let string = try #require(String(data: result, encoding: .utf8))
        let expectedPatterns = [
            "--TESTBOUNDARY\r\n",
            "Content-Disposition: form-data; name=\"text\"\r\n\r\n",
            "Hello\r\n",
            "--TESTBOUNDARY--\r\n"
        ]
        for pattern in expectedPatterns {
            #expect(string.contains(pattern))
        }
    }

    @Test
    func multipartFormWithMediaOnly() throws {
        let media = [
            BodyMaker.MediaFile(
                key: "file",
                filename: "test.txt",
                data: Data("file content".utf8),
                mimeType: "text/plain"
            )
        ]
        let boundary = "MEDIA_BOUNDARY"
        let result = try #require(BodyMaker.makeBodyWithMultipartForm(
            parameters: [],
            media: media,
            boundary: boundary
        ))
        let string = try #require(String(data: result, encoding: .utf8))
        let expectedPatterns = [
            "--MEDIA_BOUNDARY\r\n",
            "Content-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\n",
            "Content-Type: text/plain\r\n\r\n",
            "file content\r\n",
            "--MEDIA_BOUNDARY--\r\n"
        ]
        for pattern in expectedPatterns {
            #expect(string.contains(pattern))
        }
    }

    @Test
    func multipartFormWithMixedContent() throws {
        let params = [BodyMaker.Parameter(key: "title", value: "Document")]
        let media = [
            BodyMaker.MediaFile(
                key: "doc",
                filename: "doc.pdf",
                data: Data("pdf content".utf8),
                mimeType: "application/pdf"
            )
        ]
        let boundary = "MIXEDBOUNDARY"
        let result = try #require(BodyMaker.makeBodyWithMultipartForm(
            parameters: params,
            media: media,
            boundary: boundary
        ))

        let string = try #require(String(data: result, encoding: .utf8))

        // Проверяем порядок: сначала параметры, потом медиа
        let paramSection = """
        --MIXEDBOUNDARY\r\n\
        Content-Disposition: form-data; name="title"\r\n\r\n\
        Document\r\n
        """

        let mediaSection = """
        --MIXEDBOUNDARY\r\n\
        Content-Disposition: form-data; name="doc"; filename="doc.pdf"\r\n\
        Content-Type: application/pdf\r\n\r\n\
        pdf content\r\n
        """

        let closing = "--MIXEDBOUNDARY--\r\n"

        #expect(string.contains(paramSection))
        #expect(string.contains(mediaSection))
        #expect(string.contains(closing))
    }

    // MARK: - MediaFile Tests

    @Test
    func mediaFileInitialization() {
        let data = Data("test".utf8)
        let media = BodyMaker.MediaFile(
            key: "avatar",
            filename: "image.jpg",
            data: data,
            mimeType: "image/jpeg"
        )
        #expect(media.key == "avatar")
        #expect(media.filename == "image.jpg")
        #expect(media.data == data)
        #expect(media.mimeType == "image/jpeg")
    }
}

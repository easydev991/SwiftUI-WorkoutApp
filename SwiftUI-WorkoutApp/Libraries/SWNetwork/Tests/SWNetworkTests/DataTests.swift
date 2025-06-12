import Foundation
@testable import SWNetwork
import Testing

struct DataTests {
    @Test
    func prettyJson() throws {
        struct TestModel: Codable { let property: String }
        let data = try JSONEncoder().encode(TestModel(property: "property"))
        let prettyJson = data.prettyJson
        let expectedResult = """
        {
          "property" : "property"
        }
        """
        #expect(prettyJson == expectedResult)
    }

    @Test
    func validJSON_producesFormattedString() throws {
        let jsonObject = ["name": "Test", "value": 42] as [String: Any]
        let data = try JSONSerialization.data(withJSONObject: jsonObject)
        let result = data.prettyJson
        #expect(!result.isEmpty)
        #expect(result != "отсутствует")
        #expect(result.contains("\n"))
        #expect(result.contains("  "))
    }

    @Test(arguments: [Data(), Data([0x00, 0x01, 0x02])])
    func emptyOrInvalidData(_ data: Data) {
        #expect(data.prettyJson == "отсутствует")
    }

    @Test
    func minimalValidJSON_keepsContentIntegrity() throws {
        let originalJson = "{\"key\":\"value\"}"
        let data = try #require(originalJson.data(using: .utf8))
        let prettyJson = data.prettyJson
        #expect(prettyJson.contains("\"key\" : \"value\""))
        #expect(prettyJson.contains("{"))
        #expect(prettyJson.contains("}"))
    }

    @Test
    func appendString() throws {
        var data = Data()
        data.append("Hello, World!")
        let expectedData = try #require("Hello, World!".data(using: .utf8))
        #expect(data == expectedData)
    }

    @Test
    func appendEmptyString() {
        var data = Data()
        data.append("")
        #expect(data.isEmpty)
    }

    @Test
    func appendMultipleStrings() throws {
        var data = Data()
        let stringsToAppend = ["Hello", ", ", "World", "!"]
        for string in stringsToAppend {
            data.append(string)
        }
        let expectedData = try #require("Hello, World!".data(using: .utf8))
        #expect(data == expectedData)
    }

    @Test
    func appendStringToExistingData() throws {
        var data = Data("Hello".utf8)
        data.append(" World!")
        let expectedData = try #require("Hello World!".data(using: .utf8))
        #expect(data == expectedData)
    }
}

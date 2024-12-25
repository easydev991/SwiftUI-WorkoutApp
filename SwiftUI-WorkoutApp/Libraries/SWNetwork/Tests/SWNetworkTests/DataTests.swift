import Foundation
@testable import SWNetwork
import Testing

struct DataTests {
    @Test
    func prettyJson() throws {
        struct TestModel: Codable { let property: String }
        let data = try JSONEncoder().encode(TestModel(property: "property"))
        let prettyJson = try #require(data.prettyJson)
        let expectedResult = """
        {
          "property" : "property"
        }
        """
        #expect(prettyJson == expectedResult)
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

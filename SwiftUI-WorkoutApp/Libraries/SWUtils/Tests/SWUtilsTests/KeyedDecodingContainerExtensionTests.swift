import Foundation
@testable import SWUtils
import Testing

struct KeyedDecodingContainerExtensionTests {
    // MARK: - Опциональное декодирование Int

    @Test("Должен декодировать Int из строки")
    func decodeIntOrStringIfPresent_fromString() throws {
        let json = try #require("""
        {
            "value": "123"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        let value = try #require(result.value)
        #expect(value == 123)
    }

    @Test("Должен декодировать Int из числа")
    func decodeIntOrStringIfPresent_fromInt() throws {
        let json = try #require("""
        {
            "value": 123
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        let value = try #require(result.value)
        #expect(value == 123)
    }

    @Test("Должен возвращать nil для отсутствующего ключа")
    func decodeIntOrStringIfPresent_missingKey() throws {
        let json = try #require("""
        {
            "other": "value"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        #expect(result.value == nil)
    }

    @Test("Должен возвращать nil для невалидной строки")
    func decodeIntOrStringIfPresent_invalidString() throws {
        let json = try #require("""
        {
            "value": "not_a_number"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        #expect(result.value == nil)
    }

    @Test("Должен возвращать nil для пустой строки")
    func decodeIntOrStringIfPresent_emptyString() throws {
        let json = try #require("""
        {
            "value": ""
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        #expect(result.value == nil)
    }

    @Test("Должен возвращать nil для null значения")
    func decodeIntOrStringIfPresent_nullValue() throws {
        let json = try #require("""
        {
            "value": null
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        #expect(result.value == nil)
    }

    @Test("Должен корректно обрабатывать отрицательные числа")
    func decodeIntOrStringIfPresent_negativeNumber() throws {
        let json = try #require("""
        {
            "value": "-123"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        let value = try #require(result.value)
        #expect(value == -123)
    }

    @Test("Должен корректно обрабатывать ноль")
    func decodeIntOrStringIfPresent_zero() throws {
        let json = try #require("""
        {
            "value": "0"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(OptionalIntContainer.self, from: json)
        let value = try #require(result.value)
        #expect(value == 0)
    }

    // MARK: - Обязательное декодирование Int

    @Test("Должен декодировать обязательное Int из строки")
    func decodeIntOrString_fromString() throws {
        let json = try #require("""
        {
            "value": "123"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(RequiredIntContainer.self, from: json)
        #expect(result.value == 123)
    }

    @Test("Должен декодировать обязательное Int из числа")
    func decodeIntOrString_fromInt() throws {
        let json = try #require("""
        {
            "value": 123
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(RequiredIntContainer.self, from: json)
        #expect(result.value == 123)
    }

    @Test("Должен выбрасывать ошибку для отсутствующего обязательного ключа")
    func decodeIntOrString_missingKey() throws {
        let json = try #require("""
        {
            "other": "value"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(RequiredIntContainer.self, from: json)
        }
    }

    @Test("Должен выбрасывать ошибку для невалидной строки")
    func decodeIntOrString_invalidString() throws {
        let json = try #require("""
        {
            "value": "not_a_number"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(RequiredIntContainer.self, from: json)
        }
    }

    @Test("Должен выбрасывать ошибку для null значения")
    func decodeIntOrString_nullValue() throws {
        let json = try #require("""
        {
            "value": null
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(RequiredIntContainer.self, from: json)
        }
    }

    @Test("Должен корректно обрабатывать отрицательные числа")
    func decodeIntOrString_negativeNumber() throws {
        let json = try #require("""
        {
            "value": "-123"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(RequiredIntContainer.self, from: json)
        #expect(result.value == -123)
    }

    @Test("Должен корректно обрабатывать ноль")
    func decodeIntOrString_zero() throws {
        let json = try #require("""
        {
            "value": "0"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let result = try decoder.decode(RequiredIntContainer.self, from: json)
        #expect(result.value == 0)
    }
}

// MARK: - Вспомогательные структуры

private struct OptionalIntContainer: Decodable {
    let value: Int?

    enum CodingKeys: String, CodingKey {
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = container.decodeIntOrStringIfPresent(.value)
    }
}

private struct RequiredIntContainer: Decodable {
    let value: Int

    enum CodingKeys: String, CodingKey {
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decodeIntOrString(.value)
    }
}

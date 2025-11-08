import Foundation
@testable import SWModels
import Testing

struct ParkDecodingTests {
    // MARK: - Декодирование Park с полями в формате String (POST-запросы)

    @Test("Должен декодировать Park когда id приходит как строка")
    func decodePark_idAsString() throws {
        let json = try #require("""
        {
            "id": "123",
            "type_id": 1,
            "class_id": 2,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
    }

    @Test("Должен декодировать Park когда typeId приходит как строка")
    func decodePark_typeIdAsString() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": "1",
            "class_id": 2,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
    }

    @Test("Должен декодировать Park когда sizeId приходит как строка")
    func decodePark_sizeIdAsString() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": "2",
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
    }

    @Test("Должен декодировать Park когда cityId приходит как строка")
    func decodePark_cityIdAsString() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "city_id": "5",
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        let cityId = try #require(park.cityId)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
        #expect(cityId == 5)
    }

    @Test("Должен декодировать Park когда все проблемные поля (id, typeId, sizeId, cityId) приходят как строки")
    func decodePark_allFieldsAsStrings() throws {
        let json = try #require("""
        {
            "id": "123",
            "type_id": "1",
            "class_id": "2",
            "city_id": "5",
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        let cityId = try #require(park.cityId)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
        #expect(cityId == 5)
    }

    // MARK: - Декодирование Park с полями в формате Int (GET-запросы)

    @Test("Должен декодировать Park когда id приходит как число")
    func decodePark_idAsInt() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
    }

    @Test("Должен декодировать Park когда typeId приходит как число")
    func decodePark_typeIdAsInt() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
    }

    @Test("Должен декодировать Park когда sizeId приходит как число")
    func decodePark_sizeIdAsInt() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
    }

    @Test("Должен декодировать Park когда cityId приходит как число")
    func decodePark_cityIdAsInt() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "city_id": 5,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        let cityId = try #require(park.cityId)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
        #expect(cityId == 5)
    }

    @Test("Должен декодировать Park когда все проблемные поля (id, typeId, sizeId, cityId) приходят как числа")
    func decodePark_allFieldsAsInts() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "city_id": 5,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        let cityId = try #require(park.cityId)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
        #expect(cityId == 5)
    }

    // MARK: - Смешанные форматы

    @Test("Должен декодировать Park когда часть полей приходит как строки, часть как числа")
    func decodePark_mixedFormats() throws {
        let json = try #require("""
        {
            "id": "123",
            "type_id": 1,
            "class_id": "2",
            "city_id": 5,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        let cityId = try #require(park.cityId)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
        #expect(cityId == 5)
    }

    @Test("Должен декодировать Park когда cityId отсутствует (опциональное поле)")
    func decodePark_cityIdMissing() throws {
        let json = try #require("""
        {
            "id": 123,
            "type_id": 1,
            "class_id": 2,
            "latitude": "55.7558",
            "longitude": "37.6173"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let park = try decoder.decode(Park.self, from: json)
        #expect(park.id == 123)
        #expect(park.typeId == 1)
        #expect(park.sizeId == 2)
        #expect(park.cityId == nil)
    }
}

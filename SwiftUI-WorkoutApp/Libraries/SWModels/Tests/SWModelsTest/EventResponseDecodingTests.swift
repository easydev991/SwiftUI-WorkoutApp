import Foundation
@testable import SWModels
import Testing

struct EventResponseDecodingTests {
    // MARK: - Декодирование EventResponse с полем parkId в формате String (POST-запросы)

    @Test("Должен декодировать EventResponse когда parkId (area_id) приходит как строка")
    func decodeEventResponse_parkIdAsString() throws {
        let json = try #require("""
        {
            "id": 123,
            "area_id": "5"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        let parkId = try #require(event.parkId)
        #expect(event.id == 123)
        #expect(parkId == 5)
    }

    @Test("Должен декодировать EventResponse когда parkId (area_id) приходит как строка и равно null")
    func decodeEventResponse_parkIdAsStringNull() throws {
        let json = try #require("""
        {
            "id": 123,
            "area_id": null
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        #expect(event.id == 123)
        #expect(event.parkId == nil)
    }

    // MARK: - Декодирование EventResponse с полем parkId в формате Int (GET-запросы)

    @Test("Должен декодировать EventResponse когда parkId (area_id) приходит как число")
    func decodeEventResponse_parkIdAsInt() throws {
        let json = try #require("""
        {
            "id": 123,
            "area_id": 5
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        let parkId = try #require(event.parkId)
        #expect(event.id == 123)
        #expect(parkId == 5)
    }

    @Test("Должен декодировать EventResponse когда parkId (area_id) отсутствует")
    func decodeEventResponse_parkIdMissing() throws {
        let json = try #require("""
        {
            "id": 123
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        #expect(event.id == 123)
        #expect(event.parkId == nil)
    }

    // MARK: - Декодирование EventResponse с полем participantsCount в формате String (POST-запросы)

    @Test("Должен декодировать EventResponse когда participantsCount (user_count) приходит как строка")
    func decodeEventResponse_participantsCountAsString() throws {
        let json = try #require("""
        {
            "id": 123,
            "user_count": "5"
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        let participantsCount = try #require(event.participantsCount)
        #expect(event.id == 123)
        #expect(participantsCount == 5)
    }

    @Test("Должен декодировать EventResponse когда participantsCount (user_count) приходит как строка и равно null")
    func decodeEventResponse_participantsCountAsStringNull() throws {
        let json = try #require("""
        {
            "id": 123,
            "user_count": null
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        #expect(event.id == 123)
        #expect(event.participantsCount == nil)
    }

    // MARK: - Декодирование EventResponse с полем participantsCount в формате Int (GET-запросы)

    @Test("Должен декодировать EventResponse когда participantsCount (user_count) приходит как число")
    func decodeEventResponse_participantsCountAsInt() throws {
        let json = try #require("""
        {
            "id": 123,
            "user_count": 5
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        let participantsCount = try #require(event.participantsCount)
        #expect(event.id == 123)
        #expect(participantsCount == 5)
    }

    @Test("Должен декодировать EventResponse когда participantsCount (user_count) отсутствует")
    func decodeEventResponse_participantsCountMissing() throws {
        let json = try #require("""
        {
            "id": 123
        }
        """.data(using: .utf8))
        let decoder = JSONDecoder()
        let event = try decoder.decode(EventResponse.self, from: json)
        #expect(event.id == 123)
        #expect(event.participantsCount == nil)
    }
}

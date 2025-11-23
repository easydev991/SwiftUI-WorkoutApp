import Foundation
import SWModels

/// Протокол для работы с мероприятиями
public protocol EventsClient: Sendable {
    /// Запрашивает список мероприятий
    /// - Parameter type: тип мероприятия (предстоящее или прошедшее)
    /// - Returns: Список мероприятий
    func getEvents(of type: EventType) async throws -> [EventResponse]

    /// Запрашивает конкретное мероприятие
    /// - Parameter id: `id` мероприятия
    /// - Returns: Вся информация по мероприятию
    func getEvent(by id: Int) async throws -> EventResponse

    /// Отправляет новое мероприятие на сервер
    /// - Parameters:
    ///   - id: `id` мероприятия
    ///   - form: форма с данными о мероприятии
    /// - Returns: Обновленная информация о мероприятии `EventResponse`
    func saveEvent(id: Int?, form: EventForm) async throws -> EventResponse

    /// Изменить статус "пойду на мероприятие" для мероприятия
    /// - Parameters:
    ///   - go: `true` - иду на мероприятие, `false` - не иду
    ///   - eventId: `id` мероприятия
    func changeIsGoingToEvent(_ go: Bool, for eventId: Int) async throws

    /// Удалить мероприятие
    /// - Parameter eventId: `id` мероприятия
    func delete(eventId: Int) async throws
}

extension SWClient: EventsClient {
    public func getEvents(of type: EventType) async throws -> [EventResponse] {
        let endpoint: Endpoint = type == .future ? .getFutureEvents : .getPastEvents
        return try await makeResult(for: endpoint)
    }

    public func getEvent(by id: Int) async throws -> EventResponse {
        let endpoint = Endpoint.getEvent(id: id)
        return try await makeResult(for: endpoint)
    }

    public func saveEvent(id: Int?, form: EventForm) async throws -> EventResponse {
        let endpoint: Endpoint = if let id {
            .editEvent(id: id, form: form)
        } else {
            .createEvent(form: form)
        }
        return try await makeResult(for: endpoint)
    }

    public func changeIsGoingToEvent(_ go: Bool, for eventId: Int) async throws {
        let endpoint: Endpoint = go ? .postGoToEvent(eventId) : .deleteGoToEvent(eventId)
        try await makeStatus(for: endpoint)
    }

    public func delete(eventId: Int) async throws {
        let endpoint = Endpoint.deleteEvent(eventId)
        try await makeStatus(for: endpoint)
    }
}

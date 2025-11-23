import Foundation
import SWModels

/// Протокол для работы с площадками
public protocol ParksClient: Sendable, ParksUpdaterClient {
    /// Загружает список всех площадок
    ///
    /// Пока не используется, потому что:
    /// - сервер очень часто возвращает ошибку `500` при запросе всех площадок
    /// - справочник площадок хранится в `json`-файле и обновляется вручную
    /// - Returns: Список всех площадок
    func getAllParks() async throws -> [Park]

    /// Загружает данные по отдельной площадке
    /// - Parameter id: `id` площадки
    /// - Returns: Вся информация о площадке
    func getPark(id: Int) async throws -> Park

    /// Изменяет данные выбранной площадки
    /// - Parameters:
    ///   - id: `id` площадки
    ///   - form: форма с данными о площадке
    /// - Returns: Обновленная информация о площадке `Park`
    func savePark(id: Int?, form: ParkForm) async throws -> Park

    /// Удалить площадку
    /// - Parameter parkId: `id` площадки
    func delete(parkId: Int) async throws

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userId: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    func getParksForUser(_ userId: Int) async throws -> [Park]

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    ///   - parkId: `id` площадки
    func changeTrainHereStatus(_ trainHere: Bool, for parkId: Int) async throws
}

extension SWClient: ParksClient {
    public func getAllParks() async throws -> [Park] {
        let endpoint = Endpoint.getAllParks
        return try await makeResult(for: endpoint)
    }

    public func getPark(id: Int) async throws -> Park {
        let endpoint = Endpoint.getPark(id: id)
        return try await makeResult(for: endpoint)
    }

    public func savePark(id: Int?, form: ParkForm) async throws -> Park {
        let endpoint = if let id {
            Endpoint.editPark(id: id, form: form)
        } else {
            Endpoint.createPark(form: form)
        }
        return try await makeResult(for: endpoint)
    }

    public func delete(parkId: Int) async throws {
        let endpoint = Endpoint.deletePark(parkId)
        try await makeStatus(for: endpoint)
    }

    public func getParksForUser(_ userId: Int) async throws -> [Park] {
        let endpoint = Endpoint.getParksForUser(userId)
        return try await makeResult(for: endpoint)
    }

    public func changeTrainHereStatus(_ trainHere: Bool, for parkId: Int) async throws {
        let endpoint: Endpoint = trainHere ? .postTrainHere(parkId) : .deleteTrainHere(parkId)
        try await makeStatus(for: endpoint)
    }
}

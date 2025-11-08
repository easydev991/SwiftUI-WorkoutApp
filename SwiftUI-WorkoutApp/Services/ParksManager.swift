import Foundation
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Держит актуальный список всех площадок и умеет его обновлять
@MainActor
final class ParksManager: ObservableObject {
    /// Дефолтная дата - предыдущее ручное обновление файла `oldParks.json`
    ///
    /// При обновлении справочника вручную необходимо обновить тут дату -
    /// это необходимо, чтобы избежать ошибок на сервере (код 500)
    @AppStorage("lastGroundsUpdateDateString")
    private var lastParksUpdateDateString = "2025-10-25T00:00:00"
    /// Хранилище файла с площадками
    private let swStorage = SWFileManager(fileName: "SportsGrounds.json")
    /// Все площадки, доступные для отображения на карте
    @Published private(set) var fullList = [Park]()
    /// Загружены ли данные
    @Published private(set) var didLoad = false
    @Published private(set) var isLoading = false
    /// Нужно ли обновить список площадок
    ///
    /// Обновляем, если прошло больше дня с момента предыдущего обновления
    var needUpdateDefaultList: Bool {
        DateFormatterService.days(from: lastParksUpdateDateString, to: .now) > 1
    }

    init() {
        $fullList
            .map { !$0.isEmpty }
            .assign(to: &$didLoad)
    }

    /// Подготавливает дефолтный список площадок при загрузке приложения
    ///
    /// Достает список площадок из `JSON-файла` в памяти приложения
    /// Выполняется асинхронно, чтобы не блокировать главный поток
    func makeDefaultList() async throws {
        let storage = swStorage
        let parks: [Park] = try await Task.detached(priority: .userInitiated) {
            let exists = storage.documentExists
            if exists {
                return try storage.get() as [Park]
            } else {
                return try Bundle.main.decodeJson(
                    [Park].self,
                    fileName: "oldParks",
                    extension: "json"
                )
            }
        }.value
        fullList = parks
    }

    /// Загружает обновленный список площадок
    /// - Parameters:
    ///   - authHelper: Содержит токен авторизации и умеет делать логаут
    ///   - dateString: Дата, с которой нужно загрузить обновленные площадки.
    ///   Если передать `nil`, использует дефолтную дату (предыдущее ручное обновление площадок)
    func getUpdatedParks(with authHelper: AuthHelper, from dateString: String? = nil) async throws {
        isLoading = true
        defer { isLoading = false }
        let updatedParks = try await SWClient(with: authHelper).getUpdatedParks(
            from: dateString ?? lastParksUpdateDateString
        )
        try updateDefaultList(with: updatedParks)
    }

    /// Обновляет выбранную площадку
    /// - Parameter park: Площадка с новыми данными
    func manuallyUpdatePark(_ park: Park) throws {
        guard let parkIndex = fullList.firstIndex(where: { $0.id == park.id }) else {
            return
        }
        fullList[parkIndex] = park
        try saveParksInMemory()
    }

    /// Находит площадки с указанными идентификаторами
    /// - Parameter ids: Идентификаторы площадок
    /// - Returns: Список площадок по заданным идентификаторам
    func getParks(ids: [Int]) async throws -> [Park] {
        if fullList.isEmpty {
            try await makeDefaultList()
        }
        let idSet = Set(ids)
        return fullList.filter { idSet.contains($0.id) }
    }

    /// Удаляет площадку с указанным идентификатором из списка
    ///
    /// Используется при ручном удалении площадки с детального экрана площадки
    func deletePark(with id: Int) throws {
        fullList.removeAll(where: { $0.id == id })
        try saveParksInMemory()
    }
}

private extension ParksManager {
    /// Обновляем дефолтный список площадок
    func updateDefaultList(with updatedParks: [Park]) throws {
        guard !updatedParks.isEmpty else { return }
        updatedParks.forEach { park in
            if let index = fullList.firstIndex(where: { $0.id == park.id }) {
                fullList[index] = park
            } else {
                fullList.append(park)
            }
        }
        try saveParksInMemory()
        lastParksUpdateDateString = DateFormatterService.fiveMinutesAgoDateString
    }

    /// Сохраняем площадки в памяти
    func saveParksInMemory() throws {
        try swStorage.save(fullList)
    }
}

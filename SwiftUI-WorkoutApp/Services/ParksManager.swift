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
    /// - При обновлении справочника вручную необходимо обновить тут дату
    /// - Неудобно, зато спасаемся от ошибок 500 при запросе слишком старых данных
    @AppStorage("lastGroundsUpdateDateString")
    private var lastParksUpdateDateString = "2023-01-12T00:00:00"
    /// Хранилище файла с площадками
    private let swStorage = SWFileManager(fileName: "SportsGrounds.json")
    /// Все площадки, доступные для отображения на карте
    @Published private(set) var fullList = [Park]()
    /// Загружены ли данные
    @Published private(set) var didLoad = false
    /// Нужно ли обновить список площадок
    ///
    /// Обновляем, если прошло больше дня с момента предыдущего обновления
    var needUpdateDefaultList: Bool {
        DateFormatterService.days(from: lastParksUpdateDateString, to: .now) > 1
    }

    init() {
        // Подписываемся на изменения fullList
        $fullList
            .map { !$0.isEmpty }
            .assign(to: &$didLoad)
    }

    /// Подготавливает дефолтный список площадок при загрузке приложения
    ///
    /// Пытается загрузить сохраненный список площадок из памяти приложения
    func makeDefaultList() throws {
        fullList = if swStorage.documentExists {
            try swStorage.get()
        } else {
            []
        }
    }

    /// Загружает обновленный список площадок
    /// - Parameters:
    ///   - authHelper: Содержит токен авторизации и умеет делать логаут
    ///   - dateString: Дата, с которой нужно загрузить обновленные площадки.
    ///   Если передать `nil`, использует дефолтную дату (предыдущее ручное обновление площадок)
    func getUpdatedParks(with authHelper: AuthHelper, from dateString: String? = nil) async throws {
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
    func getParks(ids: [Int]) throws -> [Park] {
        if fullList.isEmpty {
            try makeDefaultList()
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

    /// Публичный метод для массового присваивания fullList и сохранения
    func setFullList(_ parks: [Park]) throws {
        fullList = parks
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

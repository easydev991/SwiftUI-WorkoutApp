import FileManager991
import Foundation
import SwiftUI
import SWModels
import Utils

/// Держит актуальный список всех площадок и умеет его обновлять
final class ParksManager: ObservableObject {
    /// Дефолтная дата - предыдущее ручное обновление файла `oldParks.json`
    ///
    /// - При обновлении справочника вручную необходимо обновить тут дату
    /// - Неудобно, зато спасаемся от ошибок 500 при запросе слишком старых данных
    @AppStorage("lastGroundsUpdateDateString")
    private(set) var lastParksUpdateDateString = "2023-01-12T00:00:00"
    /// Хранилище файла с площадками
    private let swStorage = FileManager991(fileName: "SportsGrounds.json")
    /// Все площадки, доступные для отображения на карте
    @Published private(set) var fullList = [Park]()
    /// Нужно ли обновить список площадок
    ///
    /// Обновляем, если прошло больше дня с момента предыдущего обновления
    var needUpdateDefaultList: Bool {
        DateFormatterService.days(from: lastParksUpdateDateString, to: .now) > 1
    }

    func makeDefaultList() throws {
        fullList = if swStorage.documentExists {
            try swStorage.get()
        } else {
            try Bundle.main.decodeJson(
                [Park].self,
                fileName: "oldParks",
                extension: "json"
            )
        }
    }

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

    /// Удаляет площадку с указанным идентификатором из списка
    ///
    /// Используется при ручном удалении площадки с детального экрана площадки
    func deletePark(with id: Int) throws {
        fullList.removeAll(where: { $0.id == id })
        try saveParksInMemory()
    }

    /// Сохраняем площадки в памяти
    private func saveParksInMemory() throws {
        try swStorage.save(fullList)
    }
}

import FileManager991
import Foundation
import SwiftUI
import SWModels
import Utils

/// Держит актуальный список всех площадок и умеет его обновлять
final class SportsGroundsManager: ObservableObject {
    /// Дефолтная дата - предыдущее ручное обновление файла `oldSportsGrounds.json`
    ///
    /// - При обновлении справочника вручную необходимо обновить тут дату
    /// - Неудобно, зато спасаемся от ошибок 500 при запросе слишком старых данных
    @AppStorage("lastGroundsUpdateDateString")
    private(set) var lastGroundsUpdateDateString = "2023-01-12T00:00:00"
    /// Хранилище файла с площадками
    private let swStorage = FileManager991(fileName: "SportsGrounds.json")
    /// Все площадки, доступные для отображения на карте
    @Published private(set) var fullList = [SportsGround]()
    /// Нужно ли обновить список площадок
    ///
    /// Обновляем, если прошло больше дня с момента предыдущего обновления
    var needUpdateDefaultList: Bool {
        DateFormatterService.days(from: lastGroundsUpdateDateString, to: .now) > 1
    }

    func makeDefaultList() throws {
        fullList = if swStorage.documentExists {
            try swStorage.get()
        } else {
            try Bundle.main.decodeJson(
                [SportsGround].self,
                fileName: "oldSportsGrounds",
                extension: "json"
            )
        }
    }

    /// Обновляем дефолтный список площадок
    func updateDefaultList(with updatedGrounds: [SportsGround]) throws {
        guard !updatedGrounds.isEmpty else { return }
        updatedGrounds.forEach { ground in
            if let index = fullList.firstIndex(where: { $0.id == ground.id }) {
                fullList[index] = ground
            } else {
                fullList.append(ground)
            }
        }
        try saveGroundsInMemory()
        lastGroundsUpdateDateString = DateFormatterService.fiveMinutesAgoDateString
    }

    /// Удаляет площадку с указанным идентификатором из списка
    ///
    /// Используется при ручном удалении площадки с детального экрана площадки
    func deleteGround(with id: Int) throws {
        fullList.removeAll(where: { $0.id == id })
        try saveGroundsInMemory()
    }

    /// Сохраняем площадки в памяти
    private func saveGroundsInMemory() throws {
        try swStorage.save(fullList)
    }
}

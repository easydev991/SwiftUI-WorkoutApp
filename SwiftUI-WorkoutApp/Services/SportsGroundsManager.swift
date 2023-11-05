import FileManager991
import Foundation
import SWModels

/// Держит актуальный список всех площадок и умеет его обновлять
final class SportsGroundsManager: ObservableObject {
    /// Хранилище файла с площадками
    private let swStorage = FileManager991(fileName: "SportsGrounds.json")
    /// Все площадки, доступные для отображения на карте
    @Published private(set) var fullList = [SportsGround]()

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

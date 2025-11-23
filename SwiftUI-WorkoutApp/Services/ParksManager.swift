import Foundation
import OSLog
import SwiftUI
import SWModels
import SWNetworkClient
import SWUtils

/// Держит актуальный список всех площадок и умеет его обновлять
@MainActor
final class ParksManager: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ParksManager")
    /// Дефолтная дата - предыдущее ручное обновление файла `oldParks.json`
    ///
    /// При обновлении справочника вручную необходимо обновить тут дату -
    /// это необходимо, чтобы избежать ошибок на сервере (код 500)
    @AppStorage("lastGroundsUpdateDateString")
    private(set) var lastParksUpdateDateString = "2025-10-25T00:00:00"
    /// Хранилище файла с площадками
    private let storage: SWFileManager
    /// Флаг режима UI-тестов
    private let isUITest: Bool
    /// Помощник авторизации для создания клиента
    private let authHelper: AuthHelper
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

    init(
        storage: SWFileManager = SWFileManagerImp(fileName: "SportsGrounds.json"),
        isUITest: Bool = false,
        authHelper: AuthHelper
    ) {
        self.storage = storage
        self.isUITest = isUITest
        self.authHelper = authHelper
        $fullList
            .map { !$0.isEmpty }
            .assign(to: &$didLoad)
    }

    /// Подготавливает дефолтный список площадок при загрузке приложения
    ///
    /// Достает список площадок из `JSON-файла` в памяти приложения
    /// Выполняется асинхронно, чтобы не блокировать главный поток
    func makeDefaultList() async throws {
        let storage = storage
        let documentExists = storage.documentExists

        let parks: [Park] = try await Task.detached(priority: .userInitiated) {
            if documentExists {
                do {
                    let loadedParks: [Park] = try storage.get()
                    if !loadedParks.isEmpty {
                        return loadedParks
                    }
                    self.logger.warning("makeDefaultList: файл существует, но пустой, загружаем из Bundle")
                } catch {
                    self.logger.error(
                        "makeDefaultList: ошибка при чтении файла: \(error.localizedDescription, privacy: .public), загружаем из Bundle"
                    )
                }
            }
            // Файла нет, или он пустой, или была ошибка - загружаем из Bundle
            return try Bundle.main.decodeJson(
                [Park].self,
                fileName: "oldParks",
                extension: "json"
            )
        }.value
        guard !parks.isEmpty else {
            logger.error("makeDefaultList: не удалось загрузить площадки ни из файла, ни из Bundle!")
            throw ServiceError.failedToLoadParks
        }
        fullList = parks
    }

    /// Загружает обновленный список площадок
    ///
    /// Использует `lastParksUpdateDateString` как дату для запроса обновленных площадок
    func getUpdatedParks() async throws {
        isLoading = true
        defer { isLoading = false }
        #if DEBUG
        let client: ParksUpdaterClient = isUITest
            ? MockSWClient(instantResponse: true)
            : SWClient(with: authHelper)
        #else
        let client: ParksUpdaterClient = SWClient(with: authHelper)
        #endif
        let updatedParks = try await client.getUpdatedParks(
            from: lastParksUpdateDateString
        )
        try updateDefaultList(with: updatedParks)
    }

    /// Обновляет выбранную площадку или добавляет новую
    /// - Parameter park: Площадка с новыми данными
    func manuallyUpdatePark(_ park: Park) throws {
        if let parkIndex = fullList.firstIndex(where: { $0.id == park.id }) {
            fullList[parkIndex] = park
        } else {
            fullList.append(park)
        }
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

extension ParksManager {
    enum ServiceError: Error, LocalizedError {
        case failedToLoadParks

        var errorDescription: String? {
            switch self {
            case .failedToLoadParks:
                "Не удалось загрузить список площадок"
            }
        }
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
        try storage.save(fullList)
    }
}

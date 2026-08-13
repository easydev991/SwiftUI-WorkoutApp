import Foundation

/// Протокол для работы с хранилищем файлов
public protocol SWFileManager: Sendable {
    /// Проверяет существование файла
    var documentExists: Bool { get }

    /// Сохраняет `Encodable`-объект
    func save(_ object: some Encodable) throws

    /// Загружает данные из хранилища
    func get<T: Decodable>() throws -> T
}

/// Обертка над `FileManager`
public struct SWFileManagerImp: Sendable, SWFileManager {
    private var documentDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private let fileName: String

    /// Инициализатор
    /// - Parameter fileName: Название файла с расширением, например `MyFile.json`
    public init(fileName: String) {
        self.fileName = fileName
    }

    /// Проверяет существование сохраненного файла
    public var documentExists: Bool {
        let path = documentDirectoryURL.appendingPathComponent(fileName).path()
        return FileManager.default.fileExists(atPath: path)
    }

    /// Сохраняет `Encodable`-объект
    public func save(_ object: some Encodable) throws {
        let url = documentDirectoryURL.appendingPathComponent(fileName)
        try JSONEncoder().encode(object).write(to: url, options: .atomic)
    }

    /// Загружает данные из ранее сохраненного файла
    public func get<T: Decodable>() throws -> T {
        let url = documentDirectoryURL.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

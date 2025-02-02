import Foundation

/// Обертка над `FileManager`
public struct SWFileManager {
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
        let path: String = if #available(iOS 16.0, *) {
            documentDirectoryURL.appendingPathComponent(fileName).path()
        } else {
            documentDirectoryURL.appendingPathComponent(fileName).path
        }
        return FileManager().fileExists(atPath: path)
    }

    /// Сохраняет `Encodable`-объект
    public func save(_ object: some Encodable) throws {
        let encodedData = try JSONEncoder().encode(object)
        let jsonString = String(decoding: encodedData, as: UTF8.self)
        let url = documentDirectoryURL.appendingPathComponent(fileName)
        try jsonString.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Загружает данные из ранее сохраненного файла
    public func get<T: Decodable>() throws -> T {
        let url = documentDirectoryURL.appendingPathComponent(fileName)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Удаляет сохраненный файл
    ///
    /// Если файл не существовал перед удалением, выбросит ошибку
    public func removeFile() throws {
        try FileManager.default.removeItem(at: documentDirectoryURL.appendingPathComponent(fileName))
    }
}

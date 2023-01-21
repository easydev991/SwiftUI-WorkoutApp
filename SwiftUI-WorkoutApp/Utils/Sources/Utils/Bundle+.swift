import Foundation

public extension Bundle {
    func decodeJson<T: Decodable>(
        _ type: T.Type,
        fileName: String,
        extension ext: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) throws -> T {
        guard let url = url(forResource: fileName, withExtension: ext) else {
            throw BundleError.cannotLoad(fileName)
        }
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            let result = try decoder.decode(type, from: jsonData)
            return result
        } catch {
            throw BundleError.decodingError(error)
        }
    }

    enum BundleError: Error, LocalizedError {
        case cannotLoad(_ fileName: String)
        case decodingError(_ error: Error)

        public var errorDescription: String? {
            switch self {
            case let .cannotLoad(fileName):
                return "Не удалось загрузить файл: \(fileName)"
            case let .decodingError(error):
                return "Ошибка преобразования json: \(error)"
            }
        }
    }
}

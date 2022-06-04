import Foundation

extension Bundle {
    func decodeJson<T: Decodable>(
        _ type : T.Type,
        fileName : String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) throws -> T {
        guard let url = self.url(forResource: fileName, withExtension: nil) else {
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

        var errorDescription: String? {
            switch self {
            case let .cannotLoad(fileName):
                return "Не удалось загрузить файл: \(fileName)"
            case let .decodingError(error):
                return "Ошибка преобразования json: \(error)"
            }
        }
    }
}

import Foundation
import OSLog

public extension Bundle {
    func decodeJson<T: Decodable>(
        _ type: T.Type,
        fileName: String,
        extension ext: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) throws -> T {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Bundle + decodeJson")
        guard let url = url(forResource: fileName, withExtension: ext) else {
            let error = BundleError.cannotLoad(fileName)
            logger.error("\(error.localizedDescription, privacy: .public)")
            throw error
        }
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            return try decoder.decode(type, from: jsonData)
        } catch {
            let prettyError = BundleError.decodingError(error)
            logger.error("\(prettyError.localizedDescription, privacy: .public)")
            throw prettyError
        }
    }

    enum BundleError: Error, LocalizedError {
        case cannotLoad(_ fileName: String)
        case decodingError(_ error: Error)

        public var errorDescription: String? {
            switch self {
            case let .cannotLoad(fileName):
                "Не удалось загрузить файл: \(fileName)"
            case let .decodingError(error):
                "Ошибка преобразования json: \(error)"
            }
        }
    }
}

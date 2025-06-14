import Foundation

enum ImageLoadingError: Error, LocalizedError {
    case invalidURL
    case invalidImageData(String)
    case cancelled(String)
    case networkError(_ stringURL: String, _ description: String, _ code: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Попытка загрузки без URL"
        case let .invalidImageData(stringURL):
            "Не смогли создать картинку из данных для URL: \(stringURL)"
        case let .cancelled(stringURL):
            "Отменили загрузку для URL: \(stringURL)"
        case let .networkError(stringURL, description, code):
            """
            Ошибка загрузки для \(stringURL)
            Описание: \(description)
            Код ошибки: \(code)
            """
        }
    }
}

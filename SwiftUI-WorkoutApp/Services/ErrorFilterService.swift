import Foundation

/// Фильтрует ошибку с кодом`-999` (отмена таска)
enum ErrorFilterService {
    static func message(from error: Error) -> String {
        (error as NSError).code == -999 ? "" : error.localizedDescription
    }
}

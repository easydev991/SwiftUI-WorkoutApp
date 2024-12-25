import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SWNetworkClient", category: "ErrorFilter")

/// Фильтрует ошибку с кодом`-999` (отмена таска)
///
/// Заменяет `catch CancellationError { break }`
public enum ErrorFilter {
    public static func message(from error: Error) -> String {
        let errorCode = (error as NSError).code
        if errorCode == -999 {
            logger.debug("Отфильтровали ошибку с кодом -999")
            return ""
        } else {
            return error.localizedDescription
        }
    }
}

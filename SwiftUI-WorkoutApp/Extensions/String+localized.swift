import Foundation

extension String {
    /// Локализованный вариант с использованием `NSLocalizedString`
    ///
    /// Нужен для особых случаев, когда не работает дефолтная локализация
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

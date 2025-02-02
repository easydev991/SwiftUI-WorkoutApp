import Foundation

public extension String {
    @available(*, deprecated, message: "Доработать парсинг HTML")
    var withoutHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var capitalizingFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }

    /// Количество символов без учета пробелов
    var trueCount: Int { withoutSpaces.count }

    /// Без пробелов
    var withoutSpaces: Self {
        replacingOccurrences(of: " ", with: "")
    }
}

public extension String? {
    /// `URL` без кириллицы
    var queryAllowedURL: URL? {
        guard let self else { return nil }
        if #available(iOS 17.0, *) {
            return .init(string: self, encodingInvalidCharacters: true)
        } else {
            guard let percentEncoded = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let result = URL(string: percentEncoded)
            else { return nil }
            return result
        }
    }
}

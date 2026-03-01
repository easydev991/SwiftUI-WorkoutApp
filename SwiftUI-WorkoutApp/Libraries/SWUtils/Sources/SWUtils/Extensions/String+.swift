import Foundation

public extension String {
    /// Очищает строку от HTML-тегов.
    /// - Parameter compact: Если true — заменяет переносы на пробелы и схлопывает whitespace (для превью).
    ///                      Если false — сохраняет структуру текста.
    func withoutHtml(compact: Bool = false) -> String {
        var text = self

        // 1. Предварительная обработка структурных тегов
        if compact {
            text = text
                .replacingOccurrences(of: "<br\\s*/?>", with: " ", options: .regularExpression)
                .replacingOccurrences(of: "</p>", with: " ", options: .caseInsensitive)
                .replacingOccurrences(of: "</div>", with: " ", options: .caseInsensitive)
        } else {
            text = text
                .replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
                .replacingOccurrences(of: "</p>", with: "\n\n", options: .caseInsensitive)
                .replacingOccurrences(of: "</div>", with: "\n", options: .caseInsensitive)
        }

        // 2. Удаляем все оставшиеся теги
        text = text.replacingOccurrences(of: "<[^>]*>", with: "", options: .regularExpression)

        // 3. Декодируем HTML-сущности
        text = text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")

        // 4. Финальная зачистка
        if compact {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        } else {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
        }
    }

    var capitalizingFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }

    /// Количество символов без учета пробелов
    var trueCount: Int {
        withoutSpaces.count
    }

    /// Без пробелов
    var withoutSpaces: Self {
        filter { !$0.isWhitespace }
    }
}

public extension String? {
    func withoutHtmlOrEmpty(compact: Bool = false) -> String {
        self?.withoutHtml(compact: compact) ?? ""
    }

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

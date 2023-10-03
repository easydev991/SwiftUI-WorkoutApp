public extension String {
    @available(*, deprecated, message: "Нужно корректно парсить HTML")
    var withoutHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var capitalizingFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }

    /// Количество символов без учета пробелов
    var trueCount: Int {
        replacingOccurrences(of: " ", with: "").count
    }

    /// Без пробелов
    var withoutSpaces: Self {
        replacingOccurrences(of: " ", with: "")
    }
}

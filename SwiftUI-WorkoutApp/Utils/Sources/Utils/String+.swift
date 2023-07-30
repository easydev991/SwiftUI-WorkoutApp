public extension String {
    var withoutHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
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

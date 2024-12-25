public enum BlacklistOption: String, Sendable {
    case add = "Заблокировать"
    case remove = "Разблокировать"
}

public extension BlacklistOption {
    var dialogTitle: String {
        rawValue + " пользователя?"
    }

    var dialogMessage: String {
        let firstPart = "Пользователь будет "
        let secondPart = self == .add ? "добавлен в черный список" : "удален из черного списка"
        return firstPart + secondPart
    }
}

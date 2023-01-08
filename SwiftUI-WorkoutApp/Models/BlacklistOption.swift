import Foundation

enum BlacklistOption: String {
    case add = "Заблокировать"
    case remove = "Разблокировать"
}

extension BlacklistOption {
    var dialogTitle: String {
        rawValue + " пользователя?"
    }

    var dialogMessage: String {
        let firstPart = "Пользователь будет "
        let secondPart = self == .add ? "добавлен в черный список" : "удален из черного списка"
        return firstPart + secondPart
    }
}

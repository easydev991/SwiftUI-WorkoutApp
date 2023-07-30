public enum JournalAccess: Int, CaseIterable, CustomStringConvertible {
    case all = 0
    case friends = 1
    case nobody = 2

    public init(_ rawValue: Int?) {
        switch rawValue {
        case 0: self = .all
        case 1: self = .friends
        case 2: self = .nobody
        default: self = .all
        }
    }

    public var description: String {
        switch self {
        case .all: return "Все"
        case .friends: return "Друзья"
        case .nobody: return "Только я"
        }
    }
    
    #warning("Сервер возвращает ошибку 404, ждем от Антона уточнений по API")
    /// Проверяет возможность создания записи в дневнике
    /// - Parameters:
    ///   - journalOwnerUserId: `id` владельца дневника
    ///   - journalCommentAccess: Тип доступа для создания записей в дневнике.
    ///   Настраивается владельцем дневника
    ///   - mainUserId: `id` авторизованного пользователя в мобильном приложении
    ///   - mainUserFriendsIds: Список идентификаторов друзей авторизованного пользователя
    /// - Returns: `true` - можно создать запись в дневнике, `false` - нельзя
    public static func canCreateEntry(
        journalOwnerUserId: Int,
        journalCommentAccess: Self,
        mainUserId: Int?,
        mainUserFriendsIds: [Int]
    ) -> Bool {
        let isOwner = journalOwnerUserId == mainUserId
        let isFriend = mainUserFriendsIds.contains(journalOwnerUserId)
        switch journalCommentAccess {
        case .all:
            return mainUserId != nil
        case .friends:
            return isFriend
        case .nobody:
            return isOwner
        }
    }
}

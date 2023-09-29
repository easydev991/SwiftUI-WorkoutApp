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
        case .all: "Все"
        case .friends: "Друзья"
        case .nobody: "Только я"
        }
    }

    /// Проверяет возможность создания записи в дневнике
    /// - Parameters:
    ///   - journalOwnerId: `id` владельца дневника
    ///   - journalCommentAccess: Тип доступа для создания записей в дневнике.
    ///   Настраивается владельцем дневника
    ///   - mainUserId: `id` авторизованного пользователя в мобильном приложении
    ///   - mainUserFriendsIds: Список идентификаторов друзей авторизованного пользователя
    /// - Returns: `true` - можно создать запись в дневнике, `false` - нельзя
    public static func canCreateEntry(
        journalOwnerId: Int,
        journalCommentAccess: Self,
        mainUserId: Int?,
        mainUserFriendsIds: [Int]
    ) -> Bool {
        let isOwner = journalOwnerId == mainUserId
        let isFriend = mainUserFriendsIds.contains(journalOwnerId)
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

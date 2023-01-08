enum FriendAction: String {
    case sendFriendRequest = "Добавить в друзья"
    case removeFriend = "Удалить из друзей"
}

extension FriendAction {
    var imageName: String {
        "\(self == .sendFriendRequest ? "plus" : "minus").square"
    }
}

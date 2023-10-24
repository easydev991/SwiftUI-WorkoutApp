import SWDesignSystem
import SwiftUI
import SWModels

/// Список заявок на добавление в друзья
struct FriendRequestsView: View {
    let friendRequests: [UserModel]
    let action: (_ userID: Int, _ accept: Bool) -> Void

    var body: some View {
        SectionView(headerWithPadding: "Заявки", mode: .card()) {
            LazyVStack(spacing: 0) {
                ForEach(Array(zip(friendRequests.indices, friendRequests)), id: \.0) { index, item in
                    UserRowView(
                        mode: .friendRequest(
                            .init(
                                imageURL: item.imageURL,
                                name: item.name,
                                address: item.shortAddress
                            ),
                            .init(
                                accept: { action(item.id, true) },
                                reject: { action(item.id, false) }
                            )
                        )
                    )
                    .withDivider(
                        if: index != friendRequests.endIndex - 1
                    )
                }
            }
        }
        .animation(.default, value: friendRequests)
    }
}

#if DEBUG
#Preview {
    FriendRequestsView(friendRequests: [.preview]) { _, _ in }
}
#endif

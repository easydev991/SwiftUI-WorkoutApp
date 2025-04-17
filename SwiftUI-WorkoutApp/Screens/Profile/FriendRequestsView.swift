import SWDesignSystem
import SwiftUI
import SWModels

/// Секция с заявками на добавление в друзья
struct FriendRequestsView: View {
    let friendRequests: [UserResponse]
    let action: (_ userID: Int, _ accept: Bool) -> Void

    var body: some View {
        if !friendRequests.isEmpty {
            SectionView(headerWithPadding: "Заявки", mode: .card()) {
                LazyVStack(spacing: 0) {
                    ForEach(friendRequests) { item in
                        UserRowView(
                            mode: .friendRequest(
                                .init(
                                    imageURL: item.avatarURL,
                                    name: item.userName ?? "",
                                    address: SWAddress(item.countryID, item.cityID)?.address ?? ""
                                ),
                                .init(
                                    accept: { action(item.id, true) },
                                    reject: { action(item.id, false) }
                                )
                            )
                        )
                        .withDivider(if: item != friendRequests.last)
                    }
                }
            }
            .padding(.top)
        }
    }
}

#if DEBUG
#Preview {
    FriendRequestsView(friendRequests: [.preview]) { _, _ in }
}
#endif

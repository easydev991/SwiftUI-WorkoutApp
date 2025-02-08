import SWDesignSystem
import SwiftUI
import SWModels

/// Секция с заявками на добавление в друзья
struct FriendRequestsView: View {
    let friendRequests: [UserResponse]
    let action: (_ userID: Int, _ accept: Bool) -> Void

    private var listItems: [(Int, UserResponse)] {
        Array(zip(friendRequests.indices, friendRequests))
    }

    var body: some View {
        ZStack {
            if !friendRequests.isEmpty {
                SectionView(headerWithPadding: "Заявки", mode: .card()) {
                    LazyVStack(spacing: 0) {
                        ForEach(listItems, id: \.1.id) { index, item in
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
                            .withDivider(
                                if: index != friendRequests.endIndex - 1
                            )
                        }
                    }
                }
                .padding(.top)
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

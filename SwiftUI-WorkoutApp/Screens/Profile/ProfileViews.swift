import SWDesignSystem
import SwiftUI
import SWModels

enum ProfileViews {}

extension ProfileViews {
    @ViewBuilder @MainActor
    static func makeUserInfo(for user: UserResponse) -> some View {
        ProfileView(
            imageURL: user.avatarURL,
            login: user.userName ?? "",
            genderWithAge: user.genderWithAge,
            countryAndCity: SWAddress(user.countryID, user.cityID)?.address ?? ""
        )
        .padding(24)
    }

    @ViewBuilder @MainActor
    static func makeFriends(
        for user: UserResponse,
        friendRequestsCount: Int = 0
    ) -> some View {
        if user.hasFriends || friendRequestsCount > .zero {
            NavigationLink(destination: UsersListScreen(mode: .friends(userID: user.id))) {
                FormRowView(
                    title: "Друзья",
                    trailingContent: .textWithBadgeAndChevron(
                        user.friendsCountString,
                        friendRequestsCount
                    )
                )
            }
        }
    }

    @ViewBuilder @MainActor
    static func makeUsedParks(for user: UserResponse) -> some View {
        if user.hasUsedParks {
            NavigationLink {
                ParksListScreen(mode: .usedBy(userID: user.id))
            } label: {
                FormRowView(
                    title: "Где тренируется",
                    trailingContent: .textWithChevron(user.usesParksCountString)
                )
            }
            .accessibilityIdentifier("usesParksButton")
        }
    }

    @ViewBuilder @MainActor
    static func makeAddedParks(for user: UserResponse) -> some View {
        if user.hasAddedParks {
            NavigationLink {
                ParksListScreen(mode: .added(list: user.addedParks ?? []))
            } label: {
                FormRowView(
                    title: user.addedParksString,
                    trailingContent: .textWithChevron(user.addedParksCountString)
                )
            }
        }
    }

    @ViewBuilder @MainActor
    static func makeJournals(for user: UserResponse) -> some View {
        if user.hasJournals {
            NavigationLink {
                JournalsListScreen(userID: user.id)
                    .navigationTitle("Дневники")
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                FormRowView(
                    title: "Дневники",
                    trailingContent: .textWithChevron(user.journalsCountString)
                )
            }
        }
    }
}

import SWDesignSystem
import SwiftUI
import SWModels

enum ProfileViews {}

extension ProfileViews {
    @MainActor
    static func makeUserInfo(for user: UserResponse) -> some View {
        ProfileView(
            imageURL: user.avatarURL,
            login: user.userName ?? "",
            genderWithAge: user.genderWithAge,
            countryAndCity: SWAddress(user.countryId, user.cityId)?.address ?? ""
        )
        .padding(24)
    }

    @ViewBuilder @MainActor
    static func makeFriends(
        for user: UserResponse,
        isMainUser: Bool = false,
        friendRequestsCount: Int = 0
    ) -> some View {
        let showButton = user.hasFriends || friendRequestsCount > 0
        ZStack {
            if showButton {
                NavigationLink {
                    if isMainUser {
                        MainUserFriendsListScreen(userId: user.id)
                    } else {
                        FriendsListScreen(mode: .user(id: user.id))
                    }
                } label: {
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
        .animation(.default, value: showButton)
    }

    @ViewBuilder @MainActor
    static func makeUsedParks(for user: UserResponse) -> some View {
        if user.hasUsedParks {
            NavigationLink {
                ParksListScreen(mode: .usedBy(userId: user.id))
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
        if user.hasAddedParks, let parks = user.addedParks {
            NavigationLink {
                ParksAddedByUserScreen(parks: parks)
            } label: {
                FormRowView(
                    title: user.addedParksString,
                    trailingContent: .textWithChevron(user.addedParksCountString)
                )
            }
        }
    }

    /// Делает вьюху для перехода в дневники
    /// - Parameters:
    ///   - user: Данные пользователя
    ///   - isMainUser: `true` - основной пользователь, `false` - любой другой
    /// - Returns: `NavigationLink` для перехода в дневники
    @ViewBuilder @MainActor
    static func makeJournals(
        for user: UserResponse,
        isMainUser: Bool = false
    ) -> some View {
        if user.hasJournals || isMainUser {
            NavigationLink {
                JournalsListScreen(userId: user.id)
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

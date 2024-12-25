@testable import SWModels
import Testing

struct JournalAccessTests {
    private let mainUserFriendsIds = [2, 3, 4, 5, 6]

    @Test
    func cannotCreateEntry_nobodyCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 2,
            journalCommentAccess: .nobody,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        #expect(!canCreateEntry)
    }

    @Test
    func cannotCreateEntry_onlyFriendsCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 7,
            journalCommentAccess: .friends,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        #expect(!canCreateEntry)
    }

    @Test
    func cannotCreateEntry_onlyAuthorizedCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 123,
            journalCommentAccess: .all,
            mainUserId: nil,
            mainUserFriendsIds: mainUserFriendsIds
        )
        #expect(!canCreateEntry)
    }

    @Test
    func canCreateEntry_isFriend() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 2,
            journalCommentAccess: .friends,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        #expect(canCreateEntry)
    }

    @Test
    func canCreateEntry_allAuthorizedCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 123,
            journalCommentAccess: .all,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        #expect(canCreateEntry)
    }
}

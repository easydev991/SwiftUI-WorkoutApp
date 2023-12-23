@testable import SWModels
import XCTest

final class JournalAccessTests: XCTestCase {
    private let mainUserFriendsIds = [2, 3, 4, 5, 6]

    func testCannotCreateEntry_nobodyCan() {
        let access = JournalAccess.nobody
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 2,
            journalCommentAccess: .nobody,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertFalse(canCreateEntry)
    }

    func testCannotCreateEntry_onlyFriendsCan() {
        let access = JournalAccess.friends
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 7,
            journalCommentAccess: .friends,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertFalse(canCreateEntry)
    }

    func testCannotCreateEntry_onlyAuthorizedCan() {
        let access = JournalAccess.all
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 123,
            journalCommentAccess: .friends,
            mainUserId: nil,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertFalse(canCreateEntry)
    }

    func testCanCreateEntry_isFriend() {
        let access = JournalAccess.friends
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 2,
            journalCommentAccess: .friends,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertTrue(canCreateEntry)
    }

    func testCanCreateEntry_allAuthorizedCan() {
        let access = JournalAccess.all
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 123,
            journalCommentAccess: .all,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertTrue(canCreateEntry)
    }
}

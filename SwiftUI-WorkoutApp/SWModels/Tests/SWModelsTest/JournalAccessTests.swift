@testable import SWModels
import XCTest

final class JournalAccessTests: XCTestCase {
    private let mainUserFriendsIds = [2, 3, 4, 5, 6]

    func testCannotCreateEntry_nobodyCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 2,
            journalCommentAccess: .nobody,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertFalse(canCreateEntry)
    }

    func testCannotCreateEntry_onlyFriendsCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 7,
            journalCommentAccess: .friends,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertFalse(canCreateEntry)
    }

    func testCannotCreateEntry_onlyAuthorizedCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 123,
            journalCommentAccess: .all,
            mainUserId: nil,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertFalse(canCreateEntry)
    }

    func testCanCreateEntry_isFriend() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 2,
            journalCommentAccess: .friends,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertTrue(canCreateEntry)
    }

    func testCanCreateEntry_allAuthorizedCan() {
        let canCreateEntry = JournalAccess.canCreateEntry(
            journalOwnerId: 123,
            journalCommentAccess: .all,
            mainUserId: 1,
            mainUserFriendsIds: mainUserFriendsIds
        )
        XCTAssertTrue(canCreateEntry)
    }
}

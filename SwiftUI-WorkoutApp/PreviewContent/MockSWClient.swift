import Foundation
import SWModels
import SWNetworkClient

/// Единый мок-клиент для UI-тестов, реализующий все протоколы
struct MockSWClient {
    private let authClient: MockAuthClient
    private let profileClient: MockProfileClient
    private let friendsClient: MockFriendsClient
    private let countriesClient: MockCountriesClient
    private let parksClient: MockParksClient
    private let commentsClient: MockCommentsClient
    private let eventsClient: MockEventsClient
    private let messagesClient: MockMessagesClient
    private let journalsClient: MockJournalsClient
    private let photosClient: MockPhotosClient

    init(instantResponse: Bool = true) {
        self.authClient = MockAuthClient(result: .success, instantResponse: instantResponse)
        self.profileClient = MockProfileClient(result: .success, instantResponse: instantResponse)
        self.friendsClient = MockFriendsClient(result: .success, instantResponse: instantResponse)
        self.countriesClient = MockCountriesClient(result: .success, instantResponse: instantResponse)
        self.parksClient = MockParksClient(result: .success, instantResponse: instantResponse)
        self.commentsClient = MockCommentsClient(result: .success, instantResponse: instantResponse)
        self.eventsClient = MockEventsClient(result: .success, instantResponse: instantResponse)
        self.messagesClient = MockMessagesClient(result: .success, instantResponse: instantResponse)
        self.journalsClient = MockJournalsClient(result: .success, instantResponse: instantResponse)
        self.photosClient = MockPhotosClient(result: .success, instantResponse: instantResponse)
    }
}

extension MockSWClient: AuthClient {
    func logIn(with token: String?) async throws -> Int {
        try await authClient.logIn(with: token)
    }

    func resetPassword(for login: String) async throws -> Bool {
        try await authClient.resetPassword(for: login)
    }
}

extension MockSWClient: ProfileClient {
    func getUserById(_ userId: Int) async throws -> UserResponse {
        try await profileClient.getUserById(userId)
    }

    func editUser(_ id: Int, model: MainUserForm) async throws -> UserResponse {
        try await profileClient.editUser(id, model: model)
    }

    func changePassword(current: String, new: String) async throws {
        try await profileClient.changePassword(current: current, new: new)
    }

    func getSocialUpdates(userId: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    ) {
        try await profileClient.getSocialUpdates(userId: userId)
    }
}

extension MockSWClient: FriendsClient {
    func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        try await friendsClient.getFriendsForUser(id: id)
    }

    func getFriendRequests() async throws -> [UserResponse] {
        try await friendsClient.getFriendRequests()
    }

    func respondToFriendRequest(from userId: Int, accept: Bool) async throws {
        try await friendsClient.respondToFriendRequest(from: userId, accept: accept)
    }

    func friendAction(userId: Int, option: FriendAction) async throws {
        try await friendsClient.friendAction(userId: userId, option: option)
    }

    func blacklistAction(user: UserResponse, option: BlacklistOption) async throws {
        try await friendsClient.blacklistAction(user: user, option: option)
    }

    func findUsers(with name: String) async throws -> [UserResponse] {
        try await friendsClient.findUsers(with: name)
    }

    func getBlacklist() async throws -> [UserResponse] {
        try await friendsClient.getBlacklist()
    }
}

extension MockSWClient: CountriesClient {
    func getCountries() async throws -> [Country] {
        try await countriesClient.getCountries()
    }
}

extension MockSWClient: ParksUpdaterClient {
    func getUpdatedParks(from stringDate: String) async throws -> [Park] {
        try await parksClient.getUpdatedParks(from: stringDate)
    }
}

extension MockSWClient: ParksClient {
    func getPark(id: Int) async throws -> Park {
        try await parksClient.getPark(id: id)
    }

    func savePark(id: Int?, form: ParkForm) async throws -> Park {
        try await parksClient.savePark(id: id, form: form)
    }

    func delete(parkId: Int) async throws {
        try await parksClient.delete(parkId: parkId)
    }

    func getParksForUser(_ userId: Int) async throws -> [Park] {
        try await parksClient.getParksForUser(userId)
    }

    func changeTrainHereStatus(_ trainHere: Bool, for parkId: Int) async throws {
        try await parksClient.changeTrainHereStatus(trainHere, for: parkId)
    }
}

extension MockSWClient: CommentsClient {
    func addNewEntry(to option: TextEntryOption, entryText: String) async throws {
        try await commentsClient.addNewEntry(to: option, entryText: entryText)
    }

    func editEntry(for option: TextEntryOption, entryId: Int, newEntryText: String) async throws {
        try await commentsClient.editEntry(for: option, entryId: entryId, newEntryText: newEntryText)
    }

    func deleteEntry(from option: TextEntryOption, entryId: Int) async throws {
        try await commentsClient.deleteEntry(from: option, entryId: entryId)
    }
}

extension MockSWClient: EventsClient {
    func getEvents(of type: EventType) async throws -> [EventResponse] {
        try await eventsClient.getEvents(of: type)
    }

    func getEvent(by id: Int) async throws -> EventResponse {
        try await eventsClient.getEvent(by: id)
    }

    func saveEvent(id: Int?, form: EventForm) async throws -> EventResponse {
        try await eventsClient.saveEvent(id: id, form: form)
    }

    func changeIsGoingToEvent(_ go: Bool, for eventId: Int) async throws {
        try await eventsClient.changeIsGoingToEvent(go, for: eventId)
    }

    func delete(eventId: Int) async throws {
        try await eventsClient.delete(eventId: eventId)
    }
}

extension MockSWClient: MessagesClient {
    func getDialogs() async throws -> [DialogResponse] {
        try await messagesClient.getDialogs()
    }

    func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        try await messagesClient.getMessages(for: dialog)
    }

    func sendMessage(_ message: String, to userId: Int) async throws {
        try await messagesClient.sendMessage(message, to: userId)
    }

    func markAsRead(from userId: Int) async throws {
        try await messagesClient.markAsRead(from: userId)
    }

    func deleteDialog(_ dialogId: Int) async throws {
        try await messagesClient.deleteDialog(dialogId)
    }
}

extension MockSWClient: JournalsClient {
    func getJournals(for userId: Int) async throws -> [JournalResponse] {
        try await journalsClient.getJournals(for: userId)
    }

    func editJournalSettings(
        with journalId: Int,
        title: String,
        for mainUserId: Int?,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws {
        try await journalsClient.editJournalSettings(
            with: journalId,
            title: title,
            for: mainUserId,
            viewAccess: viewAccess,
            commentAccess: commentAccess
        )
    }

    func createJournal(with title: String, for mainUserId: Int?) async throws {
        try await journalsClient.createJournal(with: title, for: mainUserId)
    }

    func getJournalEntries(for userId: Int, journalId: Int) async throws -> [JournalEntryResponse] {
        try await journalsClient.getJournalEntries(for: userId, journalId: journalId)
    }

    func deleteJournal(with journalId: Int, for mainUserId: Int?) async throws {
        try await journalsClient.deleteJournal(with: journalId, for: mainUserId)
    }
}

extension MockSWClient: PhotosClient {
    func deletePhoto(from container: PhotoContainer) async throws {
        try await photosClient.deletePhoto(from: container)
    }
}

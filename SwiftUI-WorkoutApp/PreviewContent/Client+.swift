import Foundation
import SWModels
import SWNetworkClient

/// Результат-заглушка для мок-сервисов
enum MockResult {
    case success
    case failure(error: Error = MockError())
}

extension MockResult {
    struct MockError: Error {}
}

struct MockAuthClient: AuthClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func registration(with _: MainUserForm) async throws {
        print("Имитируем запрос registration")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно зарегистрировались")
        case let .failure(error):
            throw error
        }
    }

    func logIn(with _: String?) async throws -> Int {
        print("Имитируем запрос logIn")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно авторизовались")
            return UserResponse.preview.id
        case let .failure(error):
            throw error
        }
    }

    func resetPassword(for _: String) async throws -> Bool {
        print("Имитируем запрос resetPassword")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно сбросили пароль")
            return true
        case let .failure(error):
            throw error
        }
    }
}

struct MockProfileClient: ProfileClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getUserById(_: Int) async throws -> UserResponse {
        print("Имитируем запрос getUserById")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили данные пользователя")
            return .preview
        case let .failure(error):
            throw error
        }
    }

    func editUser(_ id: Int, model: MainUserForm) async throws -> UserResponse {
        print("Имитируем запрос editUser (id=\(id))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно обновили данные пользователя")
            return .init(
                id: id,
                userName: model.userName,
                fullName: model.fullName,
                email: model.email,
                imageStringURL: nil,
                birthDateIsoString: model.birthDateIsoString,
                cityId: Int(model.city.id),
                countryId: Int(model.country.id),
                genderCode: model.genderCode,
                friendsCount: nil,
                journalsCount: nil,
                parksCountString: nil,
                addedParks: nil
            )
        case let .failure(error):
            throw error
        }
    }

    func changePassword(current _: String, new _: String) async throws {
        print("Имитируем запрос changePassword")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно изменили пароль")
        case let .failure(error):
            throw error
        }
    }

    func deleteUser() async throws {
        print("Имитируем запрос deleteUser")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили пользователя")
        case let .failure(error):
            throw error
        }
    }

    func getSocialUpdates(userId: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    ) {
        print("Имитируем запрос getSocialUpdates (userId=\(userId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили социальные обновления")
            return (
                .preview,
                UserResponse.previewFriends,
                UserResponse.previewFriendRequests,
                []
            )
        case let .failure(error):
            throw error
        }
    }

    func findUsers(with name: String) async throws -> [UserResponse] {
        print("Имитируем запрос findUsers (name=\(name))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно нашли пользователей")
            return [.previewForSearch]
        case let .failure(error):
            throw error
        }
    }
}

struct MockFriendsClient: FriendsClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        print("Имитируем запрос getFriendsForUser (id=\(id))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список друзей")
            return UserResponse.previewFriends
        case let .failure(error):
            throw error
        }
    }

    func getFriendRequests() async throws -> [UserResponse] {
        print("Имитируем запрос getFriendRequests")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список заявок в друзья")
            return UserResponse.previewFriendRequests
        case let .failure(error):
            throw error
        }
    }

    func respondToFriendRequest(from userId: Int, accept: Bool) async throws {
        print("Имитируем запрос respondToFriendRequest (userId=\(userId), accept=\(accept))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно ответили на заявку в друзья")
        case let .failure(error):
            throw error
        }
    }

    func friendAction(userId: Int, option: FriendAction) async throws {
        print("Имитируем запрос friendAction (userId=\(userId), option=\(option))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно выполнили действие с другом")
        case let .failure(error):
            throw error
        }
    }

    func blacklistAction(user: UserResponse, option: BlacklistOption) async throws {
        print("Имитируем запрос blacklistAction (userId=\(user.id), option=\(option))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно выполнили действие с черным списком")
        case let .failure(error):
            throw error
        }
    }

    func findUsers(with name: String) async throws -> [UserResponse] {
        print("Имитируем запрос findUsers (name=\(name))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно нашли пользователей")
            return [.previewForSearch]
        case let .failure(error):
            throw error
        }
    }
}

extension MockFriendsClient {
    func getBlacklist() async throws -> [UserResponse] {
        print("Имитируем запрос getBlacklist")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили черный список")
            return []
        case let .failure(error):
            throw error
        }
    }
}

struct MockCountriesClient: CountriesClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getCountries() async throws -> [Country] {
        print("Имитируем запрос getCountries")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список стран")
            return try SWAddress.countries()
        case let .failure(error):
            throw error
        }
    }
}

struct MockParksClient: ParksClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getUpdatedParks(from stringDate: String) async throws -> [Park] {
        print("Имитируем запрос getUpdatedParks (from=\(stringDate))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили обновленные площадки")
            return [.preview]
        case let .failure(error):
            throw error
        }
    }

    func getAllParks() async throws -> [Park] {
        print("Имитируем запрос getAllParks")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список всех площадок")
            return [.preview]
        case let .failure(error):
            throw error
        }
    }

    func getPark(id: Int) async throws -> Park {
        print("Имитируем запрос getPark (id=\(id))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили данные площадки")
            return .preview
        case let .failure(error):
            throw error
        }
    }

    func savePark(id: Int?, form _: ParkForm) async throws -> Park {
        print("Имитируем запрос savePark (id=\(id?.description ?? "nil"))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно сохранили площадку")
            return .preview
        case let .failure(error):
            throw error
        }
    }

    func delete(parkId: Int) async throws {
        print("Имитируем запрос delete (parkId=\(parkId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили площадку")
        case let .failure(error):
            throw error
        }
    }

    func getParksForUser(_ userId: Int) async throws -> [Park] {
        print("Имитируем запрос getParksForUser (userId=\(userId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список площадок пользователя")
            return [.preview]
        case let .failure(error):
            throw error
        }
    }

    func changeTrainHereStatus(_ trainHere: Bool, for parkId: Int) async throws {
        print("Имитируем запрос changeTrainHereStatus (trainHere=\(trainHere), parkId=\(parkId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно изменили статус тренировки на площадке")
        case let .failure(error):
            throw error
        }
    }
}

struct MockCommentsClient: CommentsClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func addNewEntry(to option: TextEntryOption, entryText: String) async throws {
        print("Имитируем запрос addNewEntry (option=\(option), entryText=\(entryText))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно добавили запись")
        case let .failure(error):
            throw error
        }
    }

    func editEntry(for option: TextEntryOption, entryId: Int, newEntryText _: String) async throws {
        print("Имитируем запрос editEntry (option=\(option), entryId=\(entryId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно изменили запись")
        case let .failure(error):
            throw error
        }
    }

    func deleteEntry(from option: TextEntryOption, entryId: Int) async throws {
        print("Имитируем запрос deleteEntry (option=\(option), entryId=\(entryId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили запись")
        case let .failure(error):
            throw error
        }
    }
}

struct MockEventsClient: EventsClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getEvents(of type: EventType) async throws -> [EventResponse] {
        print("Имитируем запрос getEvents (type=\(type))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список мероприятий")
            return EventResponse.previewList
        case let .failure(error):
            throw error
        }
    }

    func getEvent(by id: Int) async throws -> EventResponse {
        print("Имитируем запрос getEvent (id=\(id))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили данные мероприятия")
            return EventResponse.previewList.first ?? .preview
        case let .failure(error):
            throw error
        }
    }

    func saveEvent(id: Int?, form _: EventForm) async throws -> EventResponse {
        print("Имитируем запрос saveEvent (id=\(id?.description ?? "nil"))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно сохранили мероприятие")
            return .preview
        case let .failure(error):
            throw error
        }
    }

    func changeIsGoingToEvent(_ go: Bool, for eventId: Int) async throws {
        print("Имитируем запрос changeIsGoingToEvent (go=\(go), eventId=\(eventId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно изменили статус участия в мероприятии")
        case let .failure(error):
            throw error
        }
    }

    func delete(eventId: Int) async throws {
        print("Имитируем запрос delete (eventId=\(eventId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили мероприятие")
        case let .failure(error):
            throw error
        }
    }
}

struct MockMessagesClient: MessagesClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getDialogs() async throws -> [DialogResponse] {
        print("Имитируем запрос getDialogs")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список диалогов")
            return [.preview]
        case let .failure(error):
            throw error
        }
    }

    func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        print("Имитируем запрос getMessages (dialog=\(dialog))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили сообщения")
            return []
        case let .failure(error):
            throw error
        }
    }

    func sendMessage(_: String, to userId: Int) async throws {
        print("Имитируем запрос sendMessage (to=\(userId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно отправили сообщение")
        case let .failure(error):
            throw error
        }
    }

    func markAsRead(from userId: Int) async throws {
        print("Имитируем запрос markAsRead (from=\(userId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно отметили сообщения как прочитанные")
        case let .failure(error):
            throw error
        }
    }

    func deleteDialog(_ dialogId: Int) async throws {
        print("Имитируем запрос deleteDialog (dialogId=\(dialogId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили диалог")
        case let .failure(error):
            throw error
        }
    }
}

struct MockJournalsClient: JournalsClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func getJournals(for userId: Int) async throws -> [JournalResponse] {
        print("Имитируем запрос getJournals (userId=\(userId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили список дневников")
            return [.preview]
        case let .failure(error):
            throw error
        }
    }

    func getJournal(for userId: Int, journalId: Int) async throws -> JournalResponse {
        print("Имитируем запрос getJournal (userId=\(userId), journalId=\(journalId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили данные дневника")
            return .preview
        case let .failure(error):
            throw error
        }
    }

    func editJournalSettings(
        with journalId: Int,
        title _: String,
        for _: Int?,
        viewAccess _: JournalAccess,
        commentAccess _: JournalAccess
    ) async throws {
        print("Имитируем запрос editJournalSettings (journalId=\(journalId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно изменили настройки дневника")
        case let .failure(error):
            throw error
        }
    }

    func createJournal(with title: String, for _: Int?) async throws {
        print("Имитируем запрос createJournal (title=\(title))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно создали дневник")
        case let .failure(error):
            throw error
        }
    }

    func getJournalEntries(for userId: Int, journalId: Int) async throws -> [JournalEntryResponse] {
        print("Имитируем запрос getJournalEntries (userId=\(userId), journalId=\(journalId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно получили записи дневника")
            return [.preview]
        case let .failure(error):
            throw error
        }
    }

    func deleteJournal(with journalId: Int, for _: Int?) async throws {
        print("Имитируем запрос deleteJournal (journalId=\(journalId))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили дневник")
        case let .failure(error):
            throw error
        }
    }
}

struct MockPhotosClient: PhotosClient {
    let result: MockResult
    let instantResponse: Bool

    init(result: MockResult, instantResponse: Bool = false) {
        self.result = result
        self.instantResponse = instantResponse
    }

    func deletePhoto(from container: PhotoContainer) async throws {
        print("Имитируем запрос deletePhoto (container=\(container))")
        if !instantResponse {
            try await Task.sleep(for: .seconds(1))
        }
        switch result {
        case .success:
            print("Успешно удалили фотографию")
        case let .failure(error):
            throw error
        }
    }
}

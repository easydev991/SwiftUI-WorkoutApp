import Foundation
import OSLog
import SWModels
import SWNetwork

/// Сервис для обращений к серверу
public struct SWClient: Sendable {
    /// Сервис, отвечающий за обновление `UserDefaults`
    let defaults: DefaultsProtocol
    /// Сервис для отправки запросов/получения ответов от сервера
    private let service: SWNetworkProtocol

    /// Инициализатор
    /// - Parameter defaults: Сервис, отвечающий за обновление `UserDefaults`
    public init(with defaults: DefaultsProtocol) {
        self.defaults = defaults
        self.service = SWNetworkService()
    }

    #warning("Запрос не используется, т.к. регистрация в приложении отключена")
    /// Выполняет регистрацию пользователя
    ///
    /// Приложение не пропускают в `appstore`, пока на бэке поля "пол" и "дата рождения" являются обязательными,
    /// поэтому этот запрос не используется
    /// - Parameter model: необходимые для регистрации данные
    /// - Returns: Вся информация о пользователе
    public func registration(with model: MainUserForm) async throws -> Bool {
        let endpoint = Endpoint.registration(form: model)
        return try await makeStatus(for: endpoint)
    }

    /// Выполняет авторизацию
    /// - Parameter token: Токен авторизации
    /// - Returns: `id` авторизованного пользователя
    public func logIn(with token: String?) async throws -> Int {
        let endpoint = Endpoint.login
        let finalComponents = try await makeComponents(for: endpoint, with: token)
        let result: LoginResponse = try await service.requestData(components: finalComponents)
        return result.userID
    }

    /// Запрашивает обновления для пользователя и его списков: друзья, заявки, черный список
    ///
    /// - Вызывается при авторизации и при `scenePhase = active`
    /// - Список чатов не обновляет (для этого `DialogsViewModel`)
    /// - Parameter userID: Идентификатор основного пользователя
    /// - Returns: Список друзей, заявок в друзья и черный список
    public func getSocialUpdates(userID: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    ) {
        async let user = getUserByID(userID)
        async let friendsForUser = getFriendsForUser(id: userID)
        async let friendRequests = getFriendRequests()
        async let blacklist = getBlacklist()
        return try await (user, friendsForUser, friendRequests, blacklist)
    }

    /// Запрашивает данные пользователя по `id`
    ///
    /// В случае успеха сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameters:
    ///   - userID: `id` пользователя
    /// - Returns: вся информация о пользователе
    public func getUserByID(_ userID: Int) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userID)
        return try await makeResult(for: endpoint)
    }

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response: LoginResponse = try await makeResult(for: endpoint)
        return response.userID != .zero
    }

    /// Изменяет данные пользователя
    /// - Parameters:
    ///   - id: `id` пользователя
    ///   - model: данные для изменения
    /// - Returns: Актуальные данные пользователя
    public func editUser(_ id: Int, model: MainUserForm) async throws -> UserResponse {
        let endpoint = Endpoint.editUser(id: id, form: model)
        return try await makeResult(for: endpoint)
    }

    /// Меняет текущий пароль на новый
    /// - Parameters:
    ///   - current: текущий пароль
    ///   - new: новый пароль
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changePassword(current: String, new: String) async throws -> Bool {
        let endpoint = Endpoint.changePassword(currentPass: current, newPass: new)
        return try await makeStatus(for: endpoint)
    }

    #warning("Запрос не используется, т.к. регистрация в приложении отключена")
    /// Запрашивает удаление профиля текущего пользователя приложения
    public func deleteUser() async throws -> Bool {
        let endpoint = Endpoint.deleteUser
        return try await makeStatus(for: endpoint)
    }

    /// Загружает список друзей для выбранного пользователя
    ///
    /// Для главного пользователя в случае успеха сохраняет идентификаторы друзей в `defaults`
    /// - Parameter id: `id` пользователя
    /// - Returns: Список друзей выбранного пользователя
    public func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendsForUser(id: id)
        return try await makeResult(for: endpoint)
    }

    /// Загружает список заявок на добавление в друзья
    public func getFriendRequests() async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendRequests
        return try await makeResult(for: endpoint)
    }

    /// Загружает черный список пользователей
    public func getBlacklist() async throws -> [UserResponse] {
        let endpoint = Endpoint.getBlacklist
        return try await makeResult(for: endpoint)
    }

    /// Отвечает на заявку для добавления в друзья
    ///
    /// В случае успеха запрашивает список заявок повторно, а если запрос одобрен - дополнительно запрашивает список друзей
    /// - Parameters:
    ///   - userID: `id` инициатора заявки
    ///   - accept: `true` - одобрить заявку, `false` - отклонить
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func respondToFriendRequest(from userID: Int, accept: Bool) async throws -> Bool {
        let endpoint: Endpoint = accept
            ? .acceptFriendRequest(from: userID)
            : .declineFriendRequest(from: userID)
        return try await makeStatus(for: endpoint)
    }

    /// Совершает действие со статусом друга/пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя, к которому применяется действие
    ///   - option: вид действия - отправить заявку на добавление в друзья или удалить из списка друзей
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func friendAction(userID: Int, option: FriendAction) async throws -> Bool {
        let endpoint: Endpoint = option == .sendFriendRequest
            ? .sendFriendRequest(to: userID)
            : .deleteFriend(userID)
        return try await makeStatus(for: endpoint)
    }

    /// Добавляет или убирает пользователя из черного списка
    ///
    /// В случае успеха обновляет черный список в `defaults`
    /// - Parameters:
    ///   - user: Пользователь, к которому применяется действие
    ///   - option: вид действия - добавить/убрать из черного списка
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func blacklistAction(user: UserResponse, option: BlacklistOption) async throws -> Bool {
        let endpoint: Endpoint = option == .add
            ? .addToBlacklist(user.id)
            : .deleteFromBlacklist(user.id)
        return try await makeStatus(for: endpoint)
    }

    /// Ищет пользователей, чей логин содержит указанный текст
    /// - Parameter name: текст для поиска
    /// - Returns: Список пользователей, чей логин содержит указанный текст
    public func findUsers(with name: String) async throws -> [UserResponse] {
        let endpoint = Endpoint.findUsers(with: name)
        return try await makeResult(for: endpoint)
    }

    /// Загружает справочник стран/городов
    /// - Returns: Справочник стран/городов
    public func getCountries() async throws -> [Country] {
        let endpoint = Endpoint.getCountries
        return try await makeResult(for: endpoint)
    }

    /// Загружает список всех площадок
    ///
    /// Пока не используется, потому что:
    /// - сервер очень часто возвращает ошибку `500` при запросе всех площадок
    /// - справочник площадок хранится в `json`-файле и обновляется вручную
    /// - Returns: Список всех площадок
    public func getAllParks() async throws -> [Park] {
        let endpoint = Endpoint.getAllParks
        return try await makeResult(for: endpoint)
    }

    /// Загружает список всех площадок, обновленных после указанной даты
    /// - Parameter stringDate: дата отсечки для поиска обновленных площадок
    /// - Returns: Список обновленных площадок
    public func getUpdatedParks(from stringDate: String) async throws -> [Park] {
        let endpoint = Endpoint.getUpdatedParks(from: stringDate)
        return try await makeResult(for: endpoint)
    }

    /// Загружает данные по отдельной площадке
    /// - Parameter id: `id` площадки
    /// - Returns: Вся информация о площадке
    public func getPark(id: Int) async throws -> Park {
        let endpoint = Endpoint.getPark(id: id)
        return try await makeResult(for: endpoint)
    }

    /// Изменяет данные выбранной площадки
    /// - Parameters:
    ///   - id: `id` площадки
    ///   - form: форма с данными о площадке
    /// - Returns: Обновленная информация о площадке `Park`, но с ошибками, поэтому обрабатываем `ParkResult`
    public func savePark(id: Int?, form: ParkForm) async throws -> ParkResult {
        let endpoint = if let id {
            Endpoint.editPark(id: id, form: form)
        } else {
            Endpoint.createPark(form: form)
        }
        return try await makeResult(for: endpoint)
    }

    /// Добавить комментарий для площадки
    /// - Parameters:
    ///   - option: тип комментария (к площадке или мероприятию)
    ///   - comment: текст комментария
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func addNewEntry(to option: TextEntryOption, entryText: String) async throws -> Bool {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .addCommentToPark(parkID: id, comment: entryText)
        case let .event(id):
            .addCommentToEvent(eventID: id, comment: entryText)
        case let .journal(ownerId, journalId):
            .saveJournalEntry(userID: ownerId, journalID: journalId, message: entryText)
        }
        return try await makeStatus(for: endpoint)
    }

    /// Изменить свой комментарий для площадки
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryID: `id` записи
    ///   - newEntryText: текст измененной записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func editEntry(for option: TextEntryOption, entryID: Int, newEntryText: String) async throws -> Bool {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .editParkComment(
                parkID: id,
                commentID: entryID,
                newComment: newEntryText
            )
        case let .event(id):
            .editEventComment(
                eventID: id,
                commentID: entryID,
                newComment: newEntryText
            )
        case let .journal(ownerId, journalId):
            .editEntry(
                userID: ownerId,
                journalID: journalId,
                entryID: entryID,
                newEntryText: newEntryText
            )
        }
        return try await makeStatus(for: endpoint)
    }

    /// Удалить запись
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryID: `id` записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func deleteEntry(from option: TextEntryOption, entryID: Int) async throws -> Bool {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .deleteParkComment(id, commentID: entryID)
        case let .event(id):
            .deleteEventComment(id, commentID: entryID)
        case let .journal(ownerId, journalId):
            .deleteEntry(userID: ownerId, journalID: journalId, entryID: entryID)
        }
        return try await makeStatus(for: endpoint)
    }

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userID: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    public func getParksForUser(_ userID: Int) async throws -> [Park] {
        let endpoint = Endpoint.getParksForUser(userID)
        return try await makeResult(for: endpoint)
    }

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    ///   - parkID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changeTrainHereStatus(_ trainHere: Bool, for parkID: Int) async throws -> Bool {
        let endpoint: Endpoint = trainHere ? .postTrainHere(parkID) : .deleteTrainHere(parkID)
        return try await makeStatus(for: endpoint)
    }

    /// Запрашивает список мероприятий
    /// - Parameter type: тип мероприятия (предстоящее или прошедшее)
    /// - Returns: Список мероприятий
    public func getEvents(of type: EventType) async throws -> [EventResponse] {
        let endpoint: Endpoint = type == .future ? .getFutureEvents : .getPastEvents
        return try await makeResult(for: endpoint)
    }

    /// Запрашивает конкретное мероприятие
    /// - Parameter id: `id` мероприятия
    /// - Returns: Вся информация по мероприятию
    public func getEvent(by id: Int) async throws -> EventResponse {
        let endpoint = Endpoint.getEvent(id: id)
        return try await makeResult(for: endpoint)
    }

    /// Отправляет новое мероприятие на сервер
    /// - Parameters:
    ///   - id: `id` мероприятия
    ///   - form: форма с данными о мероприятии
    /// - Returns: Сервер возвращает `EventResponse`, но с неправильным форматом `area_id` (строка), поэтому обрабатываем `EventResult`
    public func saveEvent(id: Int?, form: EventForm) async throws -> EventResult {
        let endpoint: Endpoint = if let id {
            .editEvent(id: id, form: form)
        } else {
            .createEvent(form: form)
        }
        return try await makeResult(for: endpoint)
    }

    /// Изменить статус "пойду на мероприятие" для мероприятия
    /// - Parameters:
    ///   - go: `true` - иду на мероприятие, `false` - не иду
    ///   - eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changeIsGoingToEvent(_ go: Bool, for eventID: Int) async throws -> Bool {
        let endpoint: Endpoint = go ? .postGoToEvent(eventID) : .deleteGoToEvent(eventID)
        return try await makeStatus(for: endpoint)
    }

    /// Удалить мероприятие
    /// - Parameter eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func delete(eventID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteEvent(eventID)
        return try await makeStatus(for: endpoint)
    }

    /// Удалить площадку
    /// - Parameter parkID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func delete(parkID: Int) async throws -> Bool {
        let endpoint = Endpoint.deletePark(parkID)
        return try await makeStatus(for: endpoint)
    }

    /// Запрашивает список диалогов для текущего пользователя
    /// - Returns: Список диалогов
    public func getDialogs() async throws -> [DialogResponse] {
        let endpoint = Endpoint.getDialogs
        return try await makeResult(for: endpoint)
    }

    /// Запрашивает сообщения для выбранного диалога, по умолчанию лимит 30 сообщений
    /// - Parameter dialog: `id` диалога
    /// - Returns: Сообщения в диалоге
    public func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        let endpoint = Endpoint.getMessages(dialogID: dialog)
        return try await makeResult(for: endpoint)
    }

    /// Отправляет сообщение указанному пользователю
    /// - Parameters:
    ///   - message: отправляемое сообщение
    ///   - userID: `id` получателя сообщения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func sendMessage(_ message: String, to userID: Int) async throws -> Bool {
        let endpoint = Endpoint.sendMessageTo(message, userID)
        return try await makeStatus(for: endpoint)
    }

    /// Отмечает сообщения от выбранного пользователя как прочитанные
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func markAsRead(from userID: Int) async throws -> Bool {
        let endpoint = Endpoint.markAsRead(from: userID)
        return try await makeStatus(for: endpoint)
    }

    /// Удаляет выбранный диалог
    /// - Parameter dialogID: `id` диалога для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func deleteDialog(_ dialogID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteDialog(id: dialogID)
        return try await makeStatus(for: endpoint)
    }

    /// Запрашивает список дневников для выбранного пользователя
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: Список дневников
    public func getJournals(for userID: Int) async throws -> [JournalResponse] {
        let endpoint = Endpoint.getJournals(userID: userID)
        return try await makeResult(for: endpoint)
    }

    #warning("Запрос не используется")
    /// Запрашивает дневник пользователя
    ///
    /// После обновления настроек дневника при помощи метода `editJournalSettings` нет смысла делать этот запрос,
    /// т.к. актуальные данные уже есть на экране
    /// - Parameters:
    ///   - userID: `id` пользователя
    ///   - journalID: `id` выбранного дневника
    /// - Returns: Общая информация о дневнике
    public func getJournal(for userID: Int, journalID: Int) async throws -> JournalResponse {
        let endpoint = Endpoint.getJournal(userID: userID, journalID: journalID)
        return try await makeResult(for: endpoint)
    }

    /// Меняет настройки дневника
    /// - Parameters:
    ///   - journalID: `id` выбранного дневника
    ///   - title: название дневника
    ///   - mainUserID: `id` главного пользователя
    ///   - viewAccess: доступ на просмотр
    ///   - commentAccess: доступ на комментирование
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func editJournalSettings(
        with journalID: Int,
        title: String,
        for mainUserID: Int?,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws -> Bool {
        guard let mainUserID else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.editJournalSettings(
            userID: mainUserID,
            journalID: journalID,
            title: title,
            viewAccess: viewAccess.rawValue,
            commentAccess: commentAccess.rawValue
        )
        return try await makeStatus(for: endpoint)
    }

    /// - Parameters:
    ///   - title: название дневника
    ///   - mainUserID: `id` главного пользователя
    /// - Returns: Создает новый дневник для пользователя
    @discardableResult
    public func createJournal(with title: String, for mainUserID: Int?) async throws -> Bool {
        guard let mainUserID else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.createJournal(userID: mainUserID, title: title)
        return try await makeStatus(for: endpoint)
    }

    /// Запрашивает записи из дневника пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя
    ///   - journalID: `id` выбранного дневника
    /// - Returns: Все записи из выбранного дневника
    public func getJournalEntries(for userID: Int, journalID: Int) async throws -> [JournalEntryResponse] {
        let endpoint = Endpoint.getJournalEntries(userID: userID, journalID: journalID)
        return try await makeResult(for: endpoint)
    }

    /// Удаляет выбранный дневник
    /// - Parameters:
    ///   - journalID: `id` дневника для удаления
    ///   - mainUserID: `id` владельца дневника (главного пользователя)
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func deleteJournal(with journalID: Int, for mainUserID: Int?) async throws -> Bool {
        guard let mainUserID else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.deleteJournal(userID: mainUserID, journalID: journalID)
        return try await makeStatus(for: endpoint)
    }

    public func deletePhoto(from container: PhotoContainer) async throws -> Bool {
        let endpoint: Endpoint = switch container {
        case let .event(input):
            .deleteEventPhoto(
                eventID: input.containerID,
                photoID: input.photoID
            )
        case let .park(input):
            .deleteParkPhoto(
                parkID: input.containerID,
                photoID: input.photoID
            )
        }
        return try await makeStatus(for: endpoint)
    }
}

// MARK: - Обертки для SWNetworkService

private extension SWClient {
    func makeStatus(for endpoint: Endpoint) async throws -> Bool {
        do {
            let finalComponents = try await makeComponents(for: endpoint)
            return try await service.requestStatus(components: finalComponents)
        } catch APIError.invalidCredentials {
            await defaults.triggerLogout()
            throw ClientError.forceLogout
        } catch APIError.notConnectedToInternet {
            throw ClientError.noConnection
        } catch {
            throw error
        }
    }

    func makeResult<T: Decodable>(
        for endpoint: Endpoint,
        with token: String? = nil
    ) async throws -> T {
        do {
            let finalComponents = try await makeComponents(for: endpoint, with: token)
            return try await service.requestData(components: finalComponents)
        } catch APIError.invalidCredentials {
            await defaults.triggerLogout()
            throw ClientError.forceLogout
        } catch APIError.notConnectedToInternet {
            throw ClientError.noConnection
        } catch {
            throw error
        }
    }

    func makeComponents(
        for endpoint: Endpoint,
        with token: String? = nil
    ) async throws -> RequestComponents {
        let savedToken = await defaults.authToken
        return .init(
            path: endpoint.urlPath,
            queryItems: endpoint.queryItems,
            httpMethod: endpoint.method,
            hasMultipartFormData: endpoint.hasMultipartFormData,
            bodyParts: endpoint.bodyParts,
            token: token ?? savedToken
        )
    }
}

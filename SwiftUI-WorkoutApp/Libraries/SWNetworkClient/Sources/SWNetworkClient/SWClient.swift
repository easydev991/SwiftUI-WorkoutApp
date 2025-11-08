import Foundation
import OSLog
import SWModels
import SWNetwork

/// Сервис для обращений к серверу
public struct SWClient: Sendable {
    let authHelper: AuthHelper
    /// Сервис для отправки запросов/получения ответов от сервера
    private let service: SWNetworkProtocol

    /// Инициализатор
    /// - Parameter authHelper: Сервис, предоставляющий токен авторизации,
    /// и выполняющий логаут при необходимости
    public init(with authHelper: AuthHelper) {
        self.authHelper = authHelper
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
        return result.userId
    }

    /// Запрашивает обновления для пользователя и его списков: друзья, заявки, черный список
    ///
    /// - Вызывается при авторизации и при `scenePhase = active`
    /// - Список чатов не обновляет (для этого `DialogsViewModel`)
    /// - Parameter userId: Идентификатор основного пользователя
    /// - Returns: Список друзей, заявок в друзья и черный список
    public func getSocialUpdates(userId: Int) async throws -> (
        user: UserResponse,
        friends: [UserResponse],
        friendRequests: [UserResponse],
        blacklist: [UserResponse]
    ) {
        async let user = getUserById(userId)
        async let friendsForUser = getFriendsForUser(id: userId)
        async let friendRequests = getFriendRequests()
        async let blacklist = getBlacklist()
        return try await (user, friendsForUser, friendRequests, blacklist)
    }

    /// Запрашивает данные пользователя по `id`
    ///
    /// В случае успеха сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameters:
    ///   - userId: `id` пользователя
    /// - Returns: вся информация о пользователе
    public func getUserById(_ userId: Int) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userId)
        return try await makeResult(for: endpoint)
    }

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response: LoginResponse = try await makeResult(for: endpoint)
        return response.userId != .zero
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
    @discardableResult
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
    ///   - userId: `id` инициатора заявки
    ///   - accept: `true` - одобрить заявку, `false` - отклонить
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func respondToFriendRequest(from userId: Int, accept: Bool) async throws -> Bool {
        let endpoint: Endpoint = accept
            ? .acceptFriendRequest(from: userId)
            : .declineFriendRequest(from: userId)
        return try await makeStatus(for: endpoint)
    }

    /// Совершает действие со статусом друга/пользователя
    /// - Parameters:
    ///   - userId: `id` пользователя, к которому применяется действие
    ///   - option: вид действия - отправить заявку на добавление в друзья или удалить из списка друзей
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func friendAction(userId: Int, option: FriendAction) async throws -> Bool {
        let endpoint: Endpoint = option == .add
            ? .sendFriendRequest(to: userId)
            : .deleteFriend(userId)
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
    /// - Returns: Обновленная информация о площадке `Park`
    public func savePark(id: Int?, form: ParkForm) async throws -> Park {
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
            .addCommentToPark(parkId: id, comment: entryText)
        case let .event(id):
            .addCommentToEvent(eventId: id, comment: entryText)
        case let .journal(ownerId, journalId):
            .saveJournalEntry(userId: ownerId, journalId: journalId, message: entryText)
        }
        return try await makeStatus(for: endpoint)
    }

    /// Изменить свой комментарий для площадки
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryId: `id` записи
    ///   - newEntryText: текст измененной записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func editEntry(for option: TextEntryOption, entryId: Int, newEntryText: String) async throws -> Bool {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .editParkComment(
                parkId: id,
                commentId: entryId,
                newComment: newEntryText
            )
        case let .event(id):
            .editEventComment(
                eventId: id,
                commentId: entryId,
                newComment: newEntryText
            )
        case let .journal(ownerId, journalId):
            .editEntry(
                userId: ownerId,
                journalId: journalId,
                entryId: entryId,
                newEntryText: newEntryText
            )
        }
        return try await makeStatus(for: endpoint)
    }

    /// Удалить запись
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryId: `id` записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func deleteEntry(from option: TextEntryOption, entryId: Int) async throws -> Bool {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .deleteParkComment(id, commentId: entryId)
        case let .event(id):
            .deleteEventComment(id, commentId: entryId)
        case let .journal(ownerId, journalId):
            .deleteEntry(userId: ownerId, journalId: journalId, entryId: entryId)
        }
        return try await makeStatus(for: endpoint)
    }

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userId: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    public func getParksForUser(_ userId: Int) async throws -> [Park] {
        let endpoint = Endpoint.getParksForUser(userId)
        return try await makeResult(for: endpoint)
    }

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    ///   - parkId: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changeTrainHereStatus(_ trainHere: Bool, for parkId: Int) async throws -> Bool {
        let endpoint: Endpoint = trainHere ? .postTrainHere(parkId) : .deleteTrainHere(parkId)
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
    /// - Returns: Обновленная информация о мероприятии `EventResponse`
    public func saveEvent(id: Int?, form: EventForm) async throws -> EventResponse {
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
    ///   - eventId: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changeIsGoingToEvent(_ go: Bool, for eventId: Int) async throws -> Bool {
        let endpoint: Endpoint = go ? .postGoToEvent(eventId) : .deleteGoToEvent(eventId)
        return try await makeStatus(for: endpoint)
    }

    /// Удалить мероприятие
    /// - Parameter eventId: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func delete(eventId: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteEvent(eventId)
        return try await makeStatus(for: endpoint)
    }

    /// Удалить площадку
    /// - Parameter parkId: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func delete(parkId: Int) async throws -> Bool {
        let endpoint = Endpoint.deletePark(parkId)
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
        let endpoint = Endpoint.getMessages(dialogId: dialog)
        return try await makeResult(for: endpoint)
    }

    /// Отправляет сообщение указанному пользователю
    /// - Parameters:
    ///   - message: отправляемое сообщение
    ///   - userId: `id` получателя сообщения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func sendMessage(_ message: String, to userId: Int) async throws -> Bool {
        let endpoint = Endpoint.sendMessageTo(message, userId)
        return try await makeStatus(for: endpoint)
    }

    /// Отмечает сообщения от выбранного пользователя как прочитанные
    /// - Parameter userId: `id` выбранного пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func markAsRead(from userId: Int) async throws -> Bool {
        let endpoint = Endpoint.markAsRead(from: userId)
        return try await makeStatus(for: endpoint)
    }

    /// Удаляет выбранный диалог
    /// - Parameter dialogId: `id` диалога для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func deleteDialog(_ dialogId: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteDialog(id: dialogId)
        return try await makeStatus(for: endpoint)
    }

    /// Запрашивает список дневников для выбранного пользователя
    /// - Parameter userId: `id` выбранного пользователя
    /// - Returns: Список дневников
    public func getJournals(for userId: Int) async throws -> [JournalResponse] {
        let endpoint = Endpoint.getJournals(userId: userId)
        return try await makeResult(for: endpoint)
    }

    #warning("Запрос не используется")
    /// Запрашивает дневник пользователя
    ///
    /// После обновления настроек дневника при помощи метода `editJournalSettings` нет смысла делать этот запрос,
    /// т.к. актуальные данные уже есть на экране
    /// - Parameters:
    ///   - userId: `id` пользователя
    ///   - journalId: `id` выбранного дневника
    /// - Returns: Общая информация о дневнике
    public func getJournal(for userId: Int, journalId: Int) async throws -> JournalResponse {
        let endpoint = Endpoint.getJournal(userId: userId, journalId: journalId)
        return try await makeResult(for: endpoint)
    }

    /// Меняет настройки дневника
    /// - Parameters:
    ///   - journalId: `id` выбранного дневника
    ///   - title: название дневника
    ///   - mainUserId: `id` главного пользователя
    ///   - viewAccess: доступ на просмотр
    ///   - commentAccess: доступ на комментирование
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func editJournalSettings(
        with journalId: Int,
        title: String,
        for mainUserId: Int?,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws -> Bool {
        guard let mainUserId else {
            throw APIError.invalidUserId
        }
        let endpoint = Endpoint.editJournalSettings(
            userId: mainUserId,
            journalId: journalId,
            title: title,
            viewAccess: viewAccess.rawValue,
            commentAccess: commentAccess.rawValue
        )
        return try await makeStatus(for: endpoint)
    }

    /// - Parameters:
    ///   - title: название дневника
    ///   - mainUserId: `id` главного пользователя
    /// - Returns: Создает новый дневник для пользователя
    @discardableResult
    public func createJournal(with title: String, for mainUserId: Int?) async throws -> Bool {
        guard let mainUserId else {
            throw APIError.invalidUserId
        }
        let endpoint = Endpoint.createJournal(userId: mainUserId, title: title)
        return try await makeStatus(for: endpoint)
    }

    /// Запрашивает записи из дневника пользователя
    /// - Parameters:
    ///   - userId: `id` пользователя
    ///   - journalId: `id` выбранного дневника
    /// - Returns: Все записи из выбранного дневника
    public func getJournalEntries(for userId: Int, journalId: Int) async throws -> [JournalEntryResponse] {
        let endpoint = Endpoint.getJournalEntries(userId: userId, journalId: journalId)
        return try await makeResult(for: endpoint)
    }

    /// Удаляет выбранный дневник
    /// - Parameters:
    ///   - journalId: `id` дневника для удаления
    ///   - mainUserId: `id` владельца дневника (главного пользователя)
    /// - Returns: `true` в случае успеха, `false` при ошибках
    @discardableResult
    public func deleteJournal(with journalId: Int, for mainUserId: Int?) async throws -> Bool {
        guard let mainUserId else {
            throw APIError.invalidUserId
        }
        let endpoint = Endpoint.deleteJournal(userId: mainUserId, journalId: journalId)
        return try await makeStatus(for: endpoint)
    }

    public func deletePhoto(from container: PhotoContainer) async throws -> Bool {
        let endpoint: Endpoint = switch container {
        case let .event(input):
            .deleteEventPhoto(
                eventId: input.containerId,
                photoId: input.photoId
            )
        case let .park(input):
            .deleteParkPhoto(
                parkId: input.containerId,
                photoId: input.photoId
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
            await authHelper.triggerLogout()
            throw ClientError.forceLogout
        } catch APIError.notConnectedToInternet {
            throw ClientError.noConnection
        } catch APIError.notFound {
            throw ClientError.notFound
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
            await authHelper.triggerLogout()
            throw ClientError.forceLogout
        } catch APIError.notConnectedToInternet {
            throw ClientError.noConnection
        } catch APIError.notFound {
            throw ClientError.notFound
        } catch {
            throw error
        }
    }

    func makeComponents(
        for endpoint: Endpoint,
        with token: String? = nil
    ) async throws -> RequestComponents {
        let savedToken = await authHelper.authToken
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

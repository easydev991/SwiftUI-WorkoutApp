import Foundation
import OSLog
import SWModels
import SWNetwork

/// Сервис для обращений к серверу
public struct SWClient: Sendable {
    /// Сервис, отвечающий за обновление `UserDefaults`
    let defaults: DefaultsProtocol
    /// Базовый `url` сервера
    private let baseUrlString: String
    /// `true` - можно принудительно деавторизовать пользователя, `false` - не можем
    ///
    /// Если значение `true`, деавторизуем пользователя при получении кода `401` от сервера
    private let canForceLogout: Bool
    /// Сервис для отправки запросов/получения ответов от сервера
    private let service: SWNetworkService

    /// Инициализирует `SWClient` с заданными параметрами
    /// - Parameters:
    ///   - defaults: Сервис, отвечающий за обновление `UserDefaults`
    ///   - baseUrlString: Базовый `url` сервера. По умолчанию `https://workout.su/api/v3`
    ///   - timeoutInterval: Время таймаута для `URLSession`. По умолчанию `30`
    ///   - needAuth: Необходимость базовой аутентификации. По умолчанию `true`
    ///   - canForceLogout: Доступность принудительной деавторизации. По умолчанию `true`
    public init(
        with defaults: DefaultsProtocol,
        baseUrlString: String = "https://workout.su/api/v3",
        timeoutInterval: TimeInterval = 30,
        needAuth: Bool = true,
        canForceLogout: Bool = true
    ) {
        self.defaults = defaults
        self.baseUrlString = baseUrlString
        self.canForceLogout = canForceLogout
        #if DEBUG
        let enableDebugLogs = true
        #else
        let enableDebugLogs = false
        #endif
        self.service = .init(
            timeoutInterval: timeoutInterval,
            needAuth: needAuth,
            enableDebugLogs: enableDebugLogs
        )
    }

    #warning("Запрос не используется, т.к. регистрация в приложении отключена")
    /// Выполняет регистрацию пользователя
    ///
    /// Приложение не пропускают в `appstore`, пока на бэке поля "пол" и "дата рождения" являются обязательными,
    /// поэтому этот запрос не используется
    /// - Parameter model: необходимые для регистрации данные
    /// - Returns: Вся информация о пользователе
    public func registration(with model: MainUserForm) async throws {
        let endpoint = Endpoint.registration(form: model)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        try await defaults.saveAuthData(.init(login: model.userName, password: model.password))
        try await defaults.saveUserInfo(result)
    }

    /// Запрашивает `id` пользователя для входа в учетную запись
    /// - Parameters:
    ///   - login: логин или email для входа
    ///   - password: пароль от учетной записи
    public func logInWith(_ login: String, _ password: String) async throws {
        let authData = AuthData(login: login, password: password)
        try await defaults.saveAuthData(authData)
        let result = try await makeResult(LoginResponse.self, for: Endpoint.login.urlRequest(with: baseUrlString))
        try await getUserByID(result.userID, loginFlow: true)
        await getSocialUpdates(userID: result.userID)
    }

    /// Запрашивает обновления списка друзей, заявок в друзья, черного списка
    ///
    /// - Вызывается при авторизации и при `scenePhase = active`
    /// - Список чатов не обновляет
    /// - Returns: `true` - все успешно обновилось, `false` - что-то не обновилось
    @discardableResult
    public func getSocialUpdates(userID: Int?) async -> Bool {
        guard let userID else { return false }
        do {
            try await getFriendsForUser(id: userID)
            try await getFriendRequests()
            try await getBlacklist()
            return true
        } catch {
            return false
        }
    }

    /// Запрашивает данные пользователя по `id`
    ///
    /// В случае успеха сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameters:
    ///   - userID: `id` пользователя
    ///   - loginFlow: `true` - флоу авторизации пользователя, `false` - флоу получения данных другого пользователя
    /// - Returns: вся информация о пользователе
    @discardableResult
    public func getUserByID(_ userID: Int, loginFlow: Bool = false) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userID)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        let mainUserID = await defaults.mainUserInfo?.id
        if loginFlow || userID == mainUserID {
            try await defaults.saveUserInfo(result)
        }
        return result
    }

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response = try await makeResult(LoginResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        return response.userID != .zero
    }

    /// Изменяет данные пользователя
    /// - Parameters:
    ///   - id: `id` пользователя
    ///   - model: данные для изменения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func editUser(_ id: Int, model: MainUserForm) async throws -> Bool {
        let authData = try await defaults.basicAuthInfo()
        let endpoint = Endpoint.editUser(id: id, form: model)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        try await defaults.saveAuthData(.init(login: model.userName, password: authData.password))
        try await defaults.saveUserInfo(result)
        return result.userName == model.userName
    }

    /// Меняет текущий пароль на новый
    /// - Parameters:
    ///   - current: текущий пароль
    ///   - new: новый пароль
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changePassword(current: String, new: String) async throws -> Bool {
        let endpoint = Endpoint.changePassword(currentPass: current, newPass: new)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    #warning("Запрос не используется, т.к. регистрация в приложении отключена")
    /// Запрашивает удаление профиля текущего пользователя приложения
    public func deleteUser() async throws {
        let endpoint = try await Endpoint.deleteUser(auth: defaults.basicAuthInfo())
        if try await makeStatus(for: endpoint.urlRequest(with: baseUrlString)) {
            await defaults.triggerLogout()
        }
    }

    /// Загружает список друзей для выбранного пользователя
    ///
    /// Для главного пользователя в случае успеха сохраняет идентификаторы друзей в `defaults`
    /// - Parameter id: `id` пользователя
    /// - Returns: Список друзей выбранного пользователя
    @discardableResult
    public func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendsForUser(id: id)
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        if await id == defaults.mainUserInfo?.id {
            try await defaults.saveFriendsIds(result.map(\.id))
        }
        return result
    }

    /// Загружает список заявок на добавление в друзья, в случае успеха сохраняет в `defaults`
    public func getFriendRequests() async throws {
        let endpoint = Endpoint.getFriendRequests
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        try await defaults.saveFriendRequests(result)
    }

    /// Загружает черный список пользователей, в случае успеха сохраняет в `defaults`
    public func getBlacklist() async throws {
        let endpoint = Endpoint.getBlacklist
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        try await defaults.saveBlacklist(result)
    }

    /// Отвечает на заявку для добавления в друзья
    ///
    /// В случае успеха запрашивает список заявок повторно, а если запрос одобрен - дополнительно запрашивает список друзей
    /// - Parameters:
    ///   - userID: `id` инициатора заявки
    ///   - accept: `true` - одобрить заявку, `false` - отклонить
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func respondToFriendRequest(from userID: Int, accept: Bool) async throws -> Bool {
        let endpoint: Endpoint = accept
            ? .acceptFriendRequest(from: userID)
            : .declineFriendRequest(from: userID)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        if isSuccess {
            if let mainUserID = await defaults.mainUserInfo?.id, accept {
                try await getFriendsForUser(id: mainUserID)
            }
            try await getFriendRequests()
        }
        return isSuccess
    }

    /// Совершает действие со статусом друга/пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя, к которому применяется действие
    ///   - option: вид действия - отправить заявку на добавление в друзья или удалить из списка друзей
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func friendAction(userID: Int, option: FriendAction) async throws -> Bool {
        let endpoint: Endpoint = option == .sendFriendRequest
            ? .sendFriendRequest(to: userID)
            : .deleteFriend(userID)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        if let mainUserID = await defaults.mainUserInfo?.id,
           isSuccess, option == .removeFriend {
            try await getFriendsForUser(id: mainUserID)
        }
        return isSuccess
    }

    /// Добавляет или убирает пользователя из черного списка
    ///
    /// В случае успеха обновляет черный список в `defaults`
    /// - Parameters:
    ///   - user: Пользователь, к которому применяется действие
    ///   - option: вид действия - добавить/убрать из черного списка
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func blacklistAction(user: UserResponse, option: BlacklistOption) async throws -> Bool {
        let endpoint: Endpoint = option == .add
            ? .addToBlacklist(user.id)
            : .deleteFromBlacklist(user.id)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        await defaults.updateBlacklist(option: option, user: user)
        return isSuccess
    }

    /// Ищет пользователей, чей логин содержит указанный текст
    /// - Parameter name: текст для поиска
    /// - Returns: Список пользователей, чей логин содержит указанный текст
    public func findUsers(with name: String) async throws -> [UserResponse] {
        let endpoint = Endpoint.findUsers(with: name)
        return try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Загружает справочник стран/городов
    /// - Returns: Справочник стран/городов
    public func getCountries() async throws -> [Country] {
        try await makeResult([Country].self, for: Endpoint.getCountries.urlRequest(with: baseUrlString))
    }

    /// Загружает список всех площадок
    ///
    /// Пока не используется, потому что:
    /// - сервер очень часто возвращает ошибку `500` при запросе всех площадок
    /// - справочник площадок хранится в `json`-файле и обновляется вручную
    /// - Returns: Список всех площадок
    public func getAllParks() async throws -> [Park] {
        try await makeResult([Park].self, for: Endpoint.getAllParks.urlRequest(with: baseUrlString))
    }

    /// Загружает список всех площадок, обновленных после указанной даты
    /// - Parameter stringDate: дата отсечки для поиска обновленных площадок
    /// - Returns: Список обновленных площадок
    public func getUpdatedParks(from stringDate: String) async throws -> [Park] {
        let endpoint = Endpoint.getUpdatedParks(from: stringDate)
        return try await makeResult([Park].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Загружает данные по отдельной площадке
    /// - Parameter id: `id` площадки
    /// - Returns: Вся информация о площадке
    public func getPark(id: Int) async throws -> Park {
        try await makeResult(
            Park.self,
            for: Endpoint.getPark(id: id).urlRequest(with: baseUrlString)
        )
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
        return try await makeResult(ParkResult.self, for: endpoint.urlRequest(with: baseUrlString))
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
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
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
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Удалить запись
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryID: `id` записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func deleteEntry(from option: TextEntryOption, entryID: Int) async throws -> Bool {
        let endpoint: Endpoint = switch option {
        case let .park(id):
            .deleteParkComment(id, commentID: entryID)
        case let .event(id):
            .deleteEventComment(id, commentID: entryID)
        case let .journal(ownerId, journalId):
            .deleteEntry(userID: ownerId, journalID: journalId, entryID: entryID)
        }
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userID: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    public func getParksForUser(_ userID: Int) async throws -> [Park] {
        let endpoint = Endpoint.getParksForUser(userID)
        return try await makeResult([Park].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    ///   - parkID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changeTrainHereStatus(_ trainHere: Bool, for parkID: Int) async throws -> Bool {
        let endpoint: Endpoint = trainHere ? .postTrainHere(parkID) : .deleteTrainHere(parkID)
        let isOk = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        await defaults.setHasParks(trainHere)
        return isOk
    }

    /// Запрашивает список мероприятий
    /// - Parameter type: тип мероприятия (предстоящее или прошедшее)
    /// - Returns: Список мероприятий
    public func getEvents(of type: EventType) async throws -> [EventResponse] {
        let endpoint: Endpoint = type == .future ? .getFutureEvents : .getPastEvents
        return try await makeResult([EventResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Запрашивает конкретное мероприятие
    /// - Parameter id: `id` мероприятия
    /// - Returns: Вся информация по мероприятию
    public func getEvent(by id: Int) async throws -> EventResponse {
        try await makeResult(
            EventResponse.self,
            for: Endpoint.getEvent(id: id).urlRequest(with: baseUrlString)
        )
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
        return try await makeResult(EventResult.self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Изменить статус "пойду на мероприятие" для мероприятия
    /// - Parameters:
    ///   - go: `true` - иду на мероприятие, `false` - не иду
    ///   - eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func changeIsGoingToEvent(_ go: Bool, for eventID: Int) async throws -> Bool {
        let endpoint: Endpoint = go ? .postGoToEvent(eventID) : .deleteGoToEvent(eventID)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Удалить мероприятие
    /// - Parameter eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func delete(eventID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.deleteEvent(eventID).urlRequest(with: baseUrlString))
    }

    /// Удалить площадку
    /// - Parameter parkID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func delete(parkID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.deletePark(parkID).urlRequest(with: baseUrlString))
    }

    /// Запрашивает список диалогов для текущего пользователя
    /// - Returns: Список диалогов
    public func getDialogs() async throws -> [DialogResponse] {
        try await makeResult([DialogResponse].self, for: Endpoint.getDialogs.urlRequest(with: baseUrlString))
    }

    /// Запрашивает сообщения для выбранного диалога, по умолчанию лимит 30 сообщений
    /// - Parameter dialog: `id` диалога
    /// - Returns: Сообщения в диалоге
    public func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        let endpoint = Endpoint.getMessages(dialogID: dialog)
        return try await makeResult([MessageResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Отправляет сообщение указанному пользователю
    /// - Parameters:
    ///   - message: отправляемое сообщение
    ///   - userID: `id` получателя сообщения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func sendMessage(_ message: String, to userID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.sendMessageTo(message, userID).urlRequest(with: baseUrlString))
    }

    /// Отмечает сообщения от выбранного пользователя как прочитанные
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func markAsRead(from userID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.markAsRead(from: userID).urlRequest(with: baseUrlString))
    }

    /// Удаляет выбранный диалог
    /// - Parameter dialogID: `id` диалога для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func deleteDialog(_ dialogID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.deleteDialog(id: dialogID).urlRequest(with: baseUrlString))
    }

    /// Запрашивает список дневников для выбранного пользователя
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: Список дневников
    public func getJournals(for userID: Int) async throws -> [JournalResponse] {
        let endpoint = Endpoint.getJournals(userID: userID)
        let result = try await makeResult([JournalResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        if await userID == defaults.mainUserInfo?.id {
            await defaults.setHasJournals(!result.isEmpty)
        }
        return result
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
        return try await makeResult(JournalResponse.self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Меняет настройки дневника
    /// - Parameters:
    ///   - journalID: `id` выбранного дневника
    ///   - title: название дневника
    ///   - viewAccess: доступ на просмотр
    ///   - commentAccess: доступ на комментирование
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func editJournalSettings(
        for journalID: Int,
        title: String,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws -> Bool {
        guard let mainUserID = await defaults.mainUserInfo?.id else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.editJournalSettings(
            userID: mainUserID,
            journalID: journalID,
            title: title,
            viewAccess: viewAccess.rawValue,
            commentAccess: commentAccess.rawValue
        )
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Создает новый дневник для пользователя
    /// - Parameter title: название дневника
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func createJournal(with title: String) async throws -> Bool {
        guard let mainUserID = await defaults.mainUserInfo?.id else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.createJournal(userID: mainUserID, title: title)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Запрашивает записи из дневника пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя
    ///   - journalID: `id` выбранного дневника
    /// - Returns: Все записи из выбранного дневника
    public func getJournalEntries(for userID: Int, journalID: Int) async throws -> [JournalEntryResponse] {
        let endpoint = Endpoint.getJournalEntries(userID: userID, journalID: journalID)
        return try await makeResult([JournalEntryResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Удаляет выбранный дневник
    /// - Parameters:
    ///   - userID: `id` владельца дневника
    ///   - journalID: `id` дневника для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    public func deleteJournal(journalID: Int) async throws -> Bool {
        guard let mainUserID = await defaults.mainUserInfo?.id else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.deleteJournal(userID: mainUserID, journalID: journalID)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
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
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }
}

// MARK: - Обертки для SWNetworkService

extension SWClient {
    private func makeStatus(for request: URLRequest?) async throws -> Bool {
        let encodedString = try await defaults.basicAuthInfo().base64Encoded
        do {
            return try await service.makeStatus(for: request, encodedString: encodedString)
        } catch APIError.invalidCredentials {
            if canForceLogout {
                await defaults.triggerLogout()
            }
            throw APIError.invalidCredentials
        } catch {
            throw error
        }
    }

    private func makeResult<T: Decodable>(_ type: T.Type, for request: URLRequest?) async throws -> T {
        let encodedString = try await defaults.basicAuthInfo().base64Encoded
        do {
            return try await service.makeResult(type, for: request, encodedString: encodedString)
        } catch APIError.invalidCredentials {
            if canForceLogout {
                await defaults.triggerLogout()
            }
            throw APIError.invalidCredentials
        } catch {
            throw error
        }
    }
}

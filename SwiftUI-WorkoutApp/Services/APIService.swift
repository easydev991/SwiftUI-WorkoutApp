import Foundation
import SWModels

/// Сервис для обращений к серверу
struct APIService {
    /// Сервис, отвечающий за обновление `UserDefaults`
    private let defaults: DefaultsProtocol
    /// Базовый `url` сервера
    private let baseUrlString: String
    /// Время таймаута для `URLSession`
    private let timeoutInterval: TimeInterval
    /// `true` - нужна базовая аутентификация, `false` - не нужна
    ///
    /// Базовая аутентификация не нужна для запросов:
    /// - `getUpdatedSportsGrounds`
    /// - `getSportsGround`
    /// - `getEvents`
    /// - `registration`
    /// - `resetPassword`
    private let needAuth: Bool
    /// `true` - можно принудительно деавторизовать пользователя, `false` - не можем
    ///
    /// Если значение `true`, деавторизуем пользователя при получении кода `401` от сервера
    private let canForceLogout: Bool

    /// Инициализирует `APIService` с заданными параметрами
    /// - Parameters:
    ///   - defaults: Сервис, отвечающий за обновление `UserDefaults`
    ///   - baseUrlString: Базовый `url` сервера. По умолчанию `https://workout.su/api/v3`
    ///   - timeoutInterval: Время таймаута для `URLSession`. По умолчанию `15`
    ///   - needAuth: Необходимость базовой аутентификации. По умолчанию `true`
    ///   - canForceLogout: Доступность принудительной деавторизации. По умолчанию `true`
    init(
        with defaults: DefaultsProtocol,
        baseUrlString: String = "https://workout.su/api/v3",
        timeoutInterval: TimeInterval = 15,
        needAuth: Bool = true,
        canForceLogout: Bool = true
    ) {
        self.defaults = defaults
        self.baseUrlString = baseUrlString
        self.timeoutInterval = timeoutInterval
        self.needAuth = needAuth
        self.canForceLogout = canForceLogout
    }

    #warning("Запрос не используется, т.к. регистрация в приложении отключена")
    /// Выполняет регистрацию пользователя
    ///
    /// Приложение не пропускают в `appstore`, пока на бэке поля "пол" и "дата рождения" являются обязательными,
    /// поэтому этот запрос не используется
    /// - Parameter model: необходимые для регистрации данные
    /// - Returns: Вся информация о пользователе
    func registration(with model: MainUserForm) async throws {
        let endpoint = Endpoint.registration(form: model)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        try await defaults.saveAuthData(.init(login: model.userName, password: model.password))
        try await defaults.saveUserInfo(result)
    }

    /// Запрашивает `id` пользователя для входа в учетную запись
    /// - Parameters:
    ///   - login: логин или email для входа
    ///   - password: пароль от учетной записи
    func logInWith(_ login: String, _ password: String) async throws {
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
    func getSocialUpdates(userID: Int?) async -> Bool {
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
    func getUserByID(_ userID: Int, loginFlow: Bool = false) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userID)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        let mainUserID = await defaults.mainUserInfo?.userID
        if loginFlow || userID == mainUserID {
            try await defaults.saveUserInfo(result)
        }
        return result
    }

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response = try await makeResult(LoginResponse.self, for: endpoint.urlRequest(with: baseUrlString))
        return response.userID != .zero
    }

    /// Изменяет данные пользователя
    /// - Parameters:
    ///   - id: `id` пользователя
    ///   - model: данные для изменения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editUser(_ id: Int, model: MainUserForm) async throws -> Bool {
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
    func changePassword(current: String, new: String) async throws -> Bool {
        let endpoint = Endpoint.changePassword(currentPass: current, newPass: new)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    #warning("Запрос не используется, т.к. регистрация в приложении тоже отключена")
    /// Запрашивает удаление профиля текущего пользователя приложения
    func deleteUser() async throws {
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
    func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendsForUser(id: id)
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        if await id == defaults.mainUserInfo?.userID {
            try await defaults.saveFriendsIds(result.compactMap(\.userID))
        }
        return result
    }

    /// Загружает список заявок на добавление в друзья, в случае успеха сохраняет в `defaults`
    func getFriendRequests() async throws {
        let endpoint = Endpoint.getFriendRequests
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        try await defaults.saveFriendRequests(result)
    }

    /// Загружает черный список пользователей, в случае успеха сохраняет в `defaults`
    func getBlacklist() async throws {
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
    func respondToFriendRequest(from userID: Int, accept: Bool) async throws -> Bool {
        let endpoint: Endpoint = accept
            ? .acceptFriendRequest(from: userID)
            : .declineFriendRequest(from: userID)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        if isSuccess {
            if let mainUserID = await defaults.mainUserInfo?.userID, accept {
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
    func friendAction(userID: Int, option: FriendAction) async throws -> Bool {
        let endpoint: Endpoint = option == .sendFriendRequest
            ? .sendFriendRequest(to: userID)
            : .deleteFriend(userID)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        if let mainUserID = await defaults.mainUserInfo?.userID,
           isSuccess, option == .removeFriend {
            try await getFriendsForUser(id: mainUserID)
        }
        return isSuccess
    }

    /// Добавляет или убирает пользователя из черного списка
    /// - Parameters:
    ///   - userID: `id` пользователя, к которому применяется действие
    ///   - option: вид действия - добавить/убрать из черного списка
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func blacklistAction(userID: Int, option: BlacklistOption) async throws -> Bool {
        let endpoint: Endpoint = option == .add
            ? .addToBlacklist(userID)
            : .deleteFromBlacklist(userID)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Ищет пользователей, чей логин содержит указанный текст
    /// - Parameter name: текст для поиска
    /// - Returns: Список пользователей, чей логин содержит указанный текст
    func findUsers(with name: String) async throws -> [UserResponse] {
        let endpoint = Endpoint.findUsers(with: name)
        return try await makeResult([UserResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Загружает список всех площадок
    ///
    /// Пока не используется, потому что:
    /// - сервер очень часто возвращает ошибку `500` при запросе всех площадок
    /// - справочник площадок хранится в `json`-файле и обновляется вручную
    /// - Returns: Список всех площадок
    func getAllSportsGrounds() async throws -> [SportsGround] {
        try await makeResult([SportsGround].self, for: Endpoint.getAllSportsGrounds.urlRequest(with: baseUrlString))
    }

    /// Загружает список всех площадок, обновленных после указанной даты
    /// - Parameter stringDate: дата отсечки для поиска обновленных площадок
    /// - Returns: Список обновленных площадок
    func getUpdatedSportsGrounds(from stringDate: String) async throws -> [SportsGround] {
        let endpoint = Endpoint.getUpdatedSportsGrounds(from: stringDate)
        return try await makeResult([SportsGround].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Загружает данные по отдельной площадке
    /// - Parameter id: `id` площадки
    /// - Returns: Вся информация о площадке
    func getSportsGround(id: Int) async throws -> SportsGround {
        try await makeResult(
            SportsGround.self,
            for: Endpoint.getSportsGround(id: id).urlRequest(with: baseUrlString)
        )
    }

    /// Изменяет данные выбранной площадки
    /// - Parameters:
    ///   - id: `id` площадки
    ///   - form: форма с данными о площадке
    /// - Returns: Обновленная информация о площадке `SportsGround`, но с ошибками, поэтому обрабатываем `SportsGroundResult`
    func saveSportsGround(id: Int?, form: SportsGroundForm) async throws -> SportsGroundResult {
        let endpoint: Endpoint
        if let id {
            endpoint = Endpoint.editSportsGround(id: id, form: form)
        } else {
            endpoint = Endpoint.createSportsGround(form: form)
        }
        return try await makeResult(SportsGroundResult.self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Добавить комментарий для площадки
    /// - Parameters:
    ///   - option: тип комментария (к площадке или мероприятию)
    ///   - comment: текст комментария
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func addNewEntry(to option: TextEntryOption, entryText: String) async throws -> Bool {
        let endpoint: Endpoint
        switch option {
        case let .ground(id):
            endpoint = .addCommentToSportsGround(groundID: id, comment: entryText)
        case let .event(id):
            endpoint = .addCommentToEvent(eventID: id, comment: entryText)
        case let .journal(id):
            guard let mainUserID = await defaults.mainUserInfo?.userID else { throw APIError.invalidUserID }
            endpoint = .saveJournalEntry(userID: mainUserID, journalID: id, message: entryText)
        }
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Изменить свой комментарий для площадки
    /// - Parameters:
    ///   - option: тип записи
    ///   - entryID: `id` записи
    ///   - newEntryText: текст измененной записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editEntry(for option: TextEntryOption, entryID: Int, newEntryText: String) async throws -> Bool {
        let endpoint: Endpoint
        switch option {
        case let .ground(id):
            endpoint = .editGroundComment(
                groundID: id,
                commentID: entryID,
                newComment: newEntryText
            )
        case let .event(id):
            endpoint = .editEventComment(
                eventID: id,
                commentID: entryID,
                newComment: newEntryText
            )
        case let .journal(id):
            guard let mainUserID = await defaults.mainUserInfo?.userID else {
                throw APIError.invalidUserID
            }
            endpoint = .editEntry(
                userID: mainUserID,
                journalID: id,
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
    func deleteEntry(from option: TextEntryOption, entryID: Int) async throws -> Bool {
        let endpoint: Endpoint
        switch option {
        case let .ground(id):
            endpoint = .deleteGroundComment(id, commentID: entryID)
        case let .event(id):
            endpoint = .deleteEventComment(id, commentID: entryID)
        case let .journal(id):
            guard let mainUserID = await defaults.mainUserInfo?.userID else {
                throw APIError.invalidUserID
            }
            endpoint = .deleteEntry(userID: mainUserID, journalID: id, entryID: entryID)
        }
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userID: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    func getSportsGroundsForUser(_ userID: Int) async throws -> [SportsGround] {
        let endpoint = Endpoint.getSportsGroundsForUser(userID)
        return try await makeResult([SportsGround].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    ///   - groundID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func changeTrainHereStatus(_ trainHere: Bool, for groundID: Int) async throws -> Bool {
        let endpoint: Endpoint = trainHere ? .postTrainHere(groundID) : .deleteTrainHere(groundID)
        let isOk = try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
        await defaults.setHasSportsGrounds(trainHere)
        return isOk
    }

    /// Запрашивает список мероприятий
    /// - Parameter type: тип мероприятия (предстоящее или прошедшее)
    /// - Returns: Список мероприятий
    func getEvents(of type: EventType) async throws -> [EventResponse] {
        let endpoint: Endpoint = type == .future ? .getFutureEvents : .getPastEvents
        return try await makeResult([EventResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Запрашивает конкретное мероприятие
    /// - Parameter id: `id` мероприятия
    /// - Returns: Вся информация по мероприятию
    func getEvent(by id: Int) async throws -> EventResponse {
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
    func saveEvent(id: Int?, form: EventForm) async throws -> EventResult {
        let endpoint: Endpoint
        if let id {
            endpoint = .editEvent(id: id, form: form)
        } else {
            endpoint = .createEvent(form: form)
        }
        return try await makeResult(EventResult.self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Изменить статус "пойду на мероприятие" для мероприятия
    /// - Parameters:
    ///   - go: `true` - иду на мероприятие, `false` - не иду
    ///   - eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func changeIsGoingToEvent(_ go: Bool, for eventID: Int) async throws -> Bool {
        let endpoint: Endpoint = go ? .postGoToEvent(eventID) : .deleteGoToEvent(eventID)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Удалить мероприятие
    /// - Parameter eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func delete(eventID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.deleteEvent(eventID).urlRequest(with: baseUrlString))
    }

    /// Удалить площадку
    /// - Parameter groundID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func delete(groundID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.deleteSportsGround(groundID).urlRequest(with: baseUrlString))
    }

    /// Запрашивает список диалогов для текущего пользователя
    /// - Returns: Список диалогов
    func getDialogs() async throws -> [DialogResponse] {
        try await makeResult([DialogResponse].self, for: Endpoint.getDialogs.urlRequest(with: baseUrlString))
    }

    /// Запрашивает сообщения для выбранного диалога, по умолчанию лимит 30 сообщений
    /// - Parameter dialog: `id` диалога
    /// - Returns: Сообщения в диалоге
    func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        let endpoint = Endpoint.getMessages(dialogID: dialog)
        return try await makeResult([MessageResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Отправляет сообщение указанному пользователю
    /// - Parameters:
    ///   - message: отправляемое сообщение
    ///   - userID: `id` получателя сообщения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func sendMessage(_ message: String, to userID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.sendMessageTo(message, userID).urlRequest(with: baseUrlString))
    }

    /// Отмечает сообщения от выбранного пользователя как прочитанные
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func markAsRead(from userID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.markAsRead(from: userID).urlRequest(with: baseUrlString))
    }

    /// Удаляет выбранный диалог
    /// - Parameter dialogID: `id` диалога для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func deleteDialog(_ dialogID: Int) async throws -> Bool {
        try await makeStatus(for: Endpoint.deleteDialog(id: dialogID).urlRequest(with: baseUrlString))
    }

    /// Запрашивает список дневников для выбранного пользователя
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: Список дневников
    func getJournals(for userID: Int) async throws -> [JournalResponse] {
        let endpoint = Endpoint.getJournals(userID: userID)
        let result = try await makeResult([JournalResponse].self, for: endpoint.urlRequest(with: baseUrlString))
        if await userID == defaults.mainUserInfo?.userID {
            await defaults.setHasJournals(!result.isEmpty)
        }
        return result
    }

    /// Запрашивает дневник пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя
    ///   - journalID: `id` выбранного дневника
    /// - Returns: Общая информация о дневнике
    func getJournal(for userID: Int, journalID: Int) async throws -> JournalResponse {
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
    func editJournalSettings(
        for journalID: Int,
        title: String,
        viewAccess: JournalAccess,
        commentAccess: JournalAccess
    ) async throws -> Bool {
        guard let mainUserID = await defaults.mainUserInfo?.userID else {
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
    func createJournal(with title: String) async throws -> Bool {
        guard let mainUserID = await defaults.mainUserInfo?.userID else {
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
    func getJournalEntries(for userID: Int, journalID: Int) async throws -> [JournalEntryResponse] {
        let endpoint = Endpoint.getJournalEntries(userID: userID, journalID: journalID)
        return try await makeResult([JournalEntryResponse].self, for: endpoint.urlRequest(with: baseUrlString))
    }

    /// Удаляет выбранный дневник
    /// - Parameters:
    ///   - userID: `id` владельца дневника
    ///   - journalID: `id` дневника для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func deleteJournal(journalID: Int) async throws -> Bool {
        guard let mainUserID = await defaults.mainUserInfo?.userID else {
            throw APIError.invalidUserID
        }
        let endpoint = Endpoint.deleteJournal(userID: mainUserID, journalID: journalID)
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }

    func deletePhoto(from container: PhotoContainer) async throws -> Bool {
        let endpoint: Endpoint
        switch container {
        case let .event(input):
            endpoint = .deleteEventPhoto(
                eventID: input.containerID,
                photoID: input.photoID
            )
        case let .sportsGround(input):
            endpoint = .deleteGroundPhoto(
                groundID: input.containerID,
                photoID: input.photoID
            )
        }
        return try await makeStatus(for: endpoint.urlRequest(with: baseUrlString))
    }
}

private extension APIService {
    var successCode: Int { 200 }
    var forceLogoutCode: Int { 401 }

    var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval
        return .init(configuration: config)
    }

    /// Загружает данные в нужном формате или отдает ошибку
    /// - Parameters:
    ///   - type: тип, который нужно загрузить
    ///   - request: запрос, по которому нужно обратиться
    /// - Returns: Вся информация по запрошенному типу
    func makeResult<T: Decodable>(_ type: T.Type, for request: URLRequest?) async throws -> T {
        guard let request = await finalRequest(request) else { throw APIError.badRequest }
        let (data, response) = try await urlSession.data(for: request)
        return try await handle(type, data, response)
    }

    /// Выполняет действие, не требующее указания типа
    /// - Parameter request: запрос, по которому нужно обратиться
    /// - Returns: Статус действия
    func makeStatus(for request: URLRequest?) async throws -> Bool {
        guard let request = await finalRequest(request) else {
            throw APIError.badRequest
        }
        let response = try await urlSession.data(for: request).1
        return try await handle(response)
    }

    /// Формирует итоговый запрос к серверу
    /// - Parameter request: первоначальный запрос
    /// - Returns: Итоговый запрос к серверу
    func finalRequest(_ request: URLRequest?) async -> URLRequest? {
        if needAuth,
           let encodedString = try? await defaults.basicAuthInfo().base64Encoded {
            var requestWithBasicAuth = request
            requestWithBasicAuth?.setValue(
                "Basic \(encodedString)",
                forHTTPHeaderField: "Authorization"
            )
            return requestWithBasicAuth
        } else {
            return request
        }
    }

    /// Обрабатывает ответ сервера и возвращает данные в нужном формате
    func handle<T: Decodable>(_ type: T.Type, _ data: Data?, _ response: URLResponse?) async throws -> T {
        guard let data, !data.isEmpty else {
            throw APIError.noData
        }
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        guard responseCode == successCode else {
            if canForceLogout, responseCode == forceLogoutCode {
                await defaults.triggerLogout()
            }
            throw handleError(from: data, response: response)
        }
        #if DEBUG
        print("--- Получили JSON по запросу: ", (response?.url?.absoluteString).valueOrEmpty)
        print(data.prettyJson)
        do {
            _ = try JSONDecoder().decode(type, from: data)
        } catch {
            print("--- error: \(error)")
        }
        #endif
        return try JSONDecoder().decode(type, from: data)
    }

    /// Обрабатывает ответ сервера, в котором важен только статус
    func handle(_ response: URLResponse?) async throws -> Bool {
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        #if DEBUG
        print("--- Получили статус по запросу: ", (response?.url?.absoluteString).valueOrEmpty)
        print(responseCode.valueOrZero)
        #endif
        guard responseCode == successCode else {
            if canForceLogout, responseCode == forceLogoutCode {
                await defaults.triggerLogout()
            }
            throw APIError(with: responseCode)
        }
        return true
    }

    /// Обрабатывает ошибки
    /// - Parameters:
    ///   - data: данные об ошибке
    ///   - response: ответ сервера
    /// - Returns: Готовая к выводу ошибка `APIError`
    func handleError(from data: Data, response: URLResponse?) -> APIError {
        #if DEBUG
        print("--- JSON с ошибкой по запросу: ", (response?.url?.absoluteString).valueOrEmpty)
        print(data.prettyJson)
        #endif
        if let errorInfo = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return APIError(errorInfo)
        } else {
            return APIError(with: (response as? HTTPURLResponse)?.statusCode)
        }
    }
}

// MARK: - Endpoint
private extension APIService {
    enum Endpoint {
        // MARK: Регистрация
        /// **POST** ${API}/registration
        case registration(form: MainUserForm)

        // MARK: Авторизация
        /// **POST** ${API}/auth/login
        case login

        // MARK: Восстановление пароля
        /// **POST** ${API}/auth/reset
        case resetPassword(login: String)

        // MARK: Изменить данные пользователя
        /// **POST** ${API}/users/<user_id>
        case editUser(id: Int, form: MainUserForm)

        // MARK: Изменить пароль
        /// **POST** ${API}/auth/changepass
        case changePassword(currentPass: String, newPass: String)

        // MARK: Удалить профиль текущего пользователя
        /// **DELETE** ${API}/users/current
        case deleteUser(auth: AuthData)

        // MARK: Получить профиль пользователя
        /// **GET** ${API}/users/<id>
        /// `id` - идентификатор пользователя, чей профиль нужно получить
        case getUser(id: Int)

        // MARK: Получить список друзей пользователя
        /// **GET** ${API}/users/<id>/friends
        /// `id` - идентификатор пользователя, чьих друзей нужно получить
        case getFriendsForUser(id: Int)

        // MARK: Получить список заявок на добавление в друзья
        /// **GET** ${API}/friends/requests
        case getFriendRequests

        // MARK: Принять заявку на добавление в друзья
        /// **POST** ${API}/friends/<id>/accept
        case acceptFriendRequest(from: Int)

        // MARK: Отклонить заявку на добавление в друзья
        /// **DELETE**  ${API}/friends/<user_id>/accept
        case declineFriendRequest(from: Int)

        // MARK: Отправить запрос на добавление в друзья
        /// **POST**  ${API}/friends/<user_id>
        case sendFriendRequest(to: Int)

        // MARK: Удалить пользователя из списка друзей
        /// **DELETE**  ${API}/friends/<user_id>
        case deleteFriend(_ friendID: Int)

        // MARK: Получить черный список пользователей
        /// **GET** ${API}/blacklist
        case getBlacklist

        // MARK: Добавить пользователя в черный список
        /// **POST** ${API}/blacklist/<user_id>
        case addToBlacklist(_ userID: Int)

        // MARK: Удалить пользователя из черного списка
        /// **DELETE** ${API}/blacklist/<user_id>
        case deleteFromBlacklist(_ userID: Int)

        // MARK: Найти пользователей по логину
        /// **GET** ${API}/users/search?name=<user>
        case findUsers(with: String)

        // MARK: Получить список всех площадок
        /// **GET** ${API}/areas?fields=short
        ///
        /// Возвращает список с кратким набором полей, т.к. при запросе всех данных сервер не справляется с нагрузкой
        case getAllSportsGrounds

        // MARK: Получить список площадок, обновленных после указанной даты
        /// **GET** ${API}/areas/last/<date>
        case getUpdatedSportsGrounds(from: String)

        // MARK: Получить выбранную площадку:
        /// **GET** ${API}/areas/<id>
        case getSportsGround(id: Int)

        // MARK: Добавить новую спортплощадку
        /// **POST** ${API}/areas
        case createSportsGround(form: SportsGroundForm)

        // MARK: Изменить выбранную спортплощадку
        /// **POST** ${API}/areas/<id>
        case editSportsGround(id: Int, form: SportsGroundForm)

        // MARK: Удалить площадку
        /// **DELETE** ${API}/areas/<id>
        case deleteSportsGround(_ groundID: Int)

        // MARK: Добавить комментарий для площадки
        /// **POST** ${API}/areas/<area_id>/comments
        case addCommentToSportsGround(groundID: Int, comment: String)

        // MARK: Изменить свой комментарий для площадки
        /// **POST** ${API}/areas/<area_id>/comments/<comment_id>
        case editGroundComment(groundID: Int, commentID: Int, newComment: String)

        // MARK: Удалить свой комментарий для площадки
        /// **DELETE** ${API}/areas/<area_id>/comments/<comment_id>
        case deleteGroundComment(_ groundID: Int, commentID: Int)

        // MARK: Получить список площадок, где тренируется пользователь
        /// **GET** ${API}/users/<user_id>/areas
        case getSportsGroundsForUser(_ userID: Int)

        // MARK: Сообщить, что пользователь тренируется на площадке
        /// **POST** ${API}/areas/<area_id>/train
        case postTrainHere(_ groundID: Int)

        // MARK: Сообщить, что пользователь не тренируется на площадке
        /// **DELETE** ${API}/areas/<area_id>/train
        case deleteTrainHere(_ groundID: Int)

        // MARK: Получить список предстоящих мероприятий
        /// **GET** ${API}/trainings/current
        case getFutureEvents

        // MARK: Получить краткий список прошедших мероприятий
        /// **GET** ${API}/trainings/last
        case getPastEvents

        // MARK: Получить всю информацию о мероприятии
        /// **GET** ${API}/trainings/<event_id>
        case getEvent(id: Int)

        // MARK: Создать новое мероприятие
        /// **POST** ${API}/trainings
        case createEvent(form: EventForm)

        // MARK: Изменить существующее мероприятие
        /// **POST** ${API}/trainings/<id>
        case editEvent(id: Int, form: EventForm)

        // MARK: Сообщить, что пользователь пойдет на мероприятие
        /// **POST** ${API}/trainings/<event_id>/go
        case postGoToEvent(_ eventID: Int)

        // MARK: Сообщить, что пользователь не пойдет на мероприятие
        /// **DELETE** ${API}/trainings/<event_id>/go
        case deleteGoToEvent(_ eventID: Int)

        // MARK: Добавить комментарий для мероприятия
        /// **POST** ${API}/trainings/<event_id>/comments
        case addCommentToEvent(eventID: Int, comment: String)

        // MARK: Удалить свой комментарий для мероприятия
        /// **DELETE** ${API}/trainings/<event_id>/comments/<comment_id>
        case deleteEventComment(_ eventID: Int, commentID: Int)

        // MARK: Изменить свой комментарий для мероприятия
        /// **POST** ${API}/trainings/<training_id>/comments/<comment_id>
        case editEventComment(eventID: Int, commentID: Int, newComment: String)

        // MARK: Удалить мероприятие
        /// **DELETE** ${API}/trainings/<event_id>
        case deleteEvent(_ eventID: Int)

        // MARK: Получить список диалогов
        /// **GET** ${API}/dialogs
        case getDialogs

        // MARK: Получить сообщения в диалоге
        /// **GET** ${API}/dialogs/<dialog_id>/messages
        case getMessages(dialogID: Int)

        // MARK: Отправить сообщение пользователю
        /// **POST** ${API}/messages/<user_id>
        case sendMessageTo(_ message: String, _ userID: Int)

        // MARK: Отметить сообщения как прочитанные
        /// **POST** ${API}/messages/mark_as_read
        case markAsRead(from: Int)

        // MARK: Удалить выбранный диалог
        /// **DELETE** ${API}/dialogs/<dialog_id>
        case deleteDialog(id: Int)

        // MARK: Получить список дневников пользователя
        /// **GET** ${API}/users/<user_id>/journals
        case getJournals(userID: Int)

        // MARK: Получить дневник пользователя
        /// **GET** ${API}/users/<user_id>/journals/<journal_id>
        case getJournal(userID: Int, journalID: Int)

        // MARK: Изменить настройки дневника
        /// **PUT** ${API}/users/<user_id>/journals/<journal_id>
        case editJournalSettings(userID: Int, journalID: Int, title: String, viewAccess: Int, commentAccess: Int)

        // MARK: Создать новый дневник
        /// **POST** ${API}/users/<user_id>/journals
        case createJournal(userID: Int, title: String)

        // MARK: Получить записи из дневника пользователя
        /// **GET** ${API}/users/<user_id>/journals/<journal_id>/messages
        case getJournalEntries(userID: Int, journalID: Int)

        // MARK: Сохранить новую запись в дневнике пользователя
        /// **POST** ${API}/users/<user_id>/journals/<journal_id>/messages
        case saveJournalEntry(userID: Int, journalID: Int, message: String)

        // MARK: Изменить запись в дневнике пользователя
        /// **PUT** ${API}/users/<user_id>/journals/<journal_id>/messages/<id>
        case editEntry(userID: Int, journalID: Int, entryID: Int, newEntryText: String)

        // MARK: Удалить запись в дневнике пользователя
        /// **DELETE** ${API}/users/<user_id>/journals/<journal_id>/messages/<id>
        case deleteEntry(userID: Int, journalID: Int, entryID: Int)

        // MARK: Удалить дневник пользователя
        /// **DELETE** ${API}/users/<user_id>/journals/<journal_id>
        case deleteJournal(userID: Int, journalID: Int)

        // MARK: Удалить фото мероприятия
        /// **DELETE** ${API}/trainings/<event_id>/photos/<photo_id>
        case deleteEventPhoto(eventID: Int, photoID: Int)

        // MARK: Удалить фото площадки
        /// **DELETE** ${API}/areas/<area_id>/photos/<photo_id>
        case deleteGroundPhoto(groundID: Int, photoID: Int)

        /// Создает `URLRequest` с использованием базового `url`
        func urlRequest(with baseUrlString: String) -> URLRequest? {
            guard let url = URL(string: "\(baseUrlString)\(urlPath)") else { return nil }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.httpBody = httpBody
            request.allHTTPHeaderFields = headers
            return request
        }
    }
}

private extension APIService.Endpoint {
    var urlPath: String {
        switch self {
        case .registration:
            return "/registration"
        case .login:
            return "/auth/login"
        case .resetPassword:
            return "/auth/reset"
        case let .editUser(userID, _):
            return "/users/\(userID)"
        case .changePassword:
            return "/auth/changepass"
        case .deleteUser:
            return "/users/current"
        case let .getUser(id):
            return "/users/\(id)"
        case let .getFriendsForUser(id):
            return "/users/\(id)/friends"
        case .getFriendRequests:
            return "/friends/requests"
        case let .acceptFriendRequest(userID),
             let .declineFriendRequest(userID):
            return "/friends/\(userID)/accept"
        case let .sendFriendRequest(userID),
             let .deleteFriend(userID):
            return "/friends/\(userID)"
        case .getBlacklist:
            return "/blacklist"
        case let .addToBlacklist(userID),
             let .deleteFromBlacklist(userID):
            return "/blacklist/\(userID)"
        case let .findUsers(name):
            return "/users/search?name=\(name)"
        case .getAllSportsGrounds:
            return "/areas?fields=short"
        case let .getUpdatedSportsGrounds(date):
            return "/areas/last/\(date)"
        case .createSportsGround:
            return "/areas"
        case let .getSportsGround(id),
             let .editSportsGround(id, _),
             let .deleteSportsGround(id):
            return "/areas/\(id)"
        case let .addCommentToSportsGround(groundID, _):
            return "/areas/\(groundID)/comments"
        case let .editGroundComment(groundID, commentID, _):
            return "/areas/\(groundID)/comments/\(commentID)"
        case let .deleteGroundComment(groundID, commentID):
            return "/areas/\(groundID)/comments/\(commentID)"
        case let .getSportsGroundsForUser(userID):
            return "/users/\(userID)/areas"
        case let .postTrainHere(groundID), let .deleteTrainHere(groundID):
            return "/areas/\(groundID)/train"
        case .getFutureEvents:
            return "/trainings/current"
        case .getPastEvents:
            return "/trainings/last"
        case let .getEvent(id):
            return "/trainings/\(id)"
        case .createEvent:
            return "/trainings"
        case let .postGoToEvent(id), let .deleteGoToEvent(id):
            return "/trainings/\(id)/go"
        case let .addCommentToEvent(id, _):
            return "/trainings/\(id)/comments"
        case let .deleteEventComment(eventID, commentID):
            return "/trainings/\(eventID)/comments/\(commentID)"
        case let .editEventComment(eventID, commentID, _):
            return "/trainings/\(eventID)/comments/\(commentID)"
        case let .deleteEvent(id), let .editEvent(id, _):
            return "/trainings/\(id)"
        case .getDialogs:
            return "/dialogs"
        case let .getMessages(dialogID):
            return "/dialogs/\(dialogID)/messages"
        case let .sendMessageTo(_, userID):
            return "/messages/\(userID)"
        case .markAsRead:
            return "/messages/mark_as_read"
        case let .deleteDialog(dialogID):
            return "/dialogs/\(dialogID)"
        case let .getJournals(userID),
             let .createJournal(userID, _):
            return "/users/\(userID)/journals"
        case let .getJournal(userID, journalID),
             let .deleteJournal(userID, journalID),
             let .editJournalSettings(userID, journalID, _, _, _):
            return "/users/\(userID)/journals/\(journalID)"
        case let .getJournalEntries(userID, journalID),
             let .saveJournalEntry(userID, journalID, _):
            return "/users/\(userID)/journals/\(journalID)/messages"
        case let .editEntry(userID, journalID, entryID, _),
             let .deleteEntry(userID, journalID, entryID):
            return "/users/\(userID)/journals/\(journalID)/messages/\(entryID)"
        case let .deleteEventPhoto(eventID, photoID):
            return "/trainings/\(eventID)/photos/\(photoID)"
        case let .deleteGroundPhoto(groundID, photoID):
            return "/areas/\(groundID)/photos/\(photoID)"
        }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    var method: HTTPMethod {
        switch self {
        case .registration, .login, .editUser, .resetPassword,
             .changePassword, .acceptFriendRequest, .sendFriendRequest,
             .addCommentToSportsGround, .editGroundComment, .postTrainHere,
             .createEvent, .editEvent, .postGoToEvent, .addToBlacklist,
             .addCommentToEvent, .editEventComment, .sendMessageTo,
             .createJournal, .markAsRead, .saveJournalEntry,
             .createSportsGround, .editSportsGround:
            return .post
        case .getUser, .getFriendsForUser, .getFriendRequests,
             .getAllSportsGrounds, .getSportsGround,
             .findUsers, .getSportsGroundsForUser, .getBlacklist,
             .getFutureEvents, .getPastEvents, .getEvent,
             .getDialogs, .getMessages, .getJournals,
             .getJournal, .getJournalEntries,
             .getUpdatedSportsGrounds:
            return .get
        case .declineFriendRequest, .deleteFriend, .deleteFromBlacklist,
             .deleteGroundComment, .deleteTrainHere,
             .deleteUser, .deleteGoToEvent,
             .deleteEventComment, .deleteEvent,
             .deleteDialog, .deleteJournal,
             .deleteEntry, .deleteSportsGround,
             .deleteEventPhoto, .deleteGroundPhoto:
            return .delete
        case .editJournalSettings, .editEntry:
            return .put
        }
    }

    enum HTTPHeader {
        static let boundary = "FFF"
        enum Key: String { case contentType = "Content-Type" }
        static var withMultipartFormData: [String: String] {
            [Key.contentType.rawValue: "multipart/form-data; boundary=\(boundary)"]
        }
    }

    var headers: [String: String] {
        switch self {
        case .createSportsGround, .editSportsGround, .createEvent, .editEvent:
            return HTTPHeader.withMultipartFormData
        default: return [:]
        }
    }

    enum Parameter {
        enum Key: String {
            case name, fullname, email, password,
                 comment, message, title, description,
                 date, address, latitude, longitude
            case areaID = "area_id"
            case viewAccess = "view_access"
            case commentAccess = "comment_access"
            case genderCode = "gender"
            case usernameOrEmail = "username_or_email"
            case newPassword = "new_password"
            case countryID = "country_id"
            case cityID = "city_id"
            case birthDate = "birth_date"
            case fromUserID = "from_user_id"
            case typeID = "type_id"
            case classID = "class_id"
        }

        static func makeBody(from dict: [Key: String]) -> Data? {
            dict
                .map { $0.key.rawValue + "=" + $0.value }
                .joined(separator: "&")
                .data(using: .utf8)
        }

        static func makeBodyWithMultipartForm(from dict: [Key: String], with media: [MediaFile]?) -> Data {
            let boundary = HTTPHeader.boundary
            let lineBreak = "\r\n"
            var body = Data()
            dict.forEach { key, value in
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key.rawValue)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
            media?.forEach { photo in
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
            body.append("--\(boundary)--\(lineBreak)")
            return body
        }
    }

    var httpBody: Data? {
        switch self {
        case .login, .getUser, .getFriendsForUser, .getFriendRequests,
             .acceptFriendRequest, .declineFriendRequest, .findUsers,
             .sendFriendRequest, .deleteFriend, .getBlacklist,
             .addToBlacklist, .deleteFromBlacklist,
             .getSportsGround, .deleteGroundComment, .getSportsGroundsForUser,
             .postTrainHere, .deleteTrainHere, .deleteUser,
             .getFutureEvents, .getPastEvents, .getEvent,
             .postGoToEvent, .deleteGoToEvent,
             .deleteEventComment, .deleteEvent, .getDialogs,
             .getMessages, .deleteDialog, .getJournals,
             .getJournal, .getJournalEntries, .deleteEntry,
             .deleteJournal, .getAllSportsGrounds,
             .getUpdatedSportsGrounds, .deleteSportsGround,
             .deleteEventPhoto, .deleteGroundPhoto:
            return nil
        case let .registration(form):
            return Parameter.makeBody(
                from: [
                    .name: form.userName,
                    .fullname: form.fullName,
                    .email: form.email,
                    .password: form.password,
                    .genderCode: form.genderCode.description,
                    .countryID: form.country.id,
                    .cityID: form.city.id,
                    .birthDate: form.birthDateIsoString
                ]
            )
        case let .editUser(_, form):
            return Parameter.makeBody(
                from: [
                    .name: form.userName,
                    .fullname: form.fullName,
                    .email: form.email,
                    .genderCode: form.genderCode.description,
                    .countryID: form.country.id,
                    .cityID: form.city.id,
                    .birthDate: form.birthDateIsoString
                ]
            )
        case let .resetPassword(login):
            return Parameter.makeBody(from: [.usernameOrEmail: login])
        case let .changePassword(current, new):
            return Parameter.makeBody(from: [.password: current, .newPassword: new])
        case let .addCommentToSportsGround(_, comment),
             let .addCommentToEvent(_, comment),
             let .editGroundComment(_, _, comment),
             let .editEventComment(_, _, comment):
            return Parameter.makeBody(from: [.comment: comment])
        case let .sendMessageTo(message, _):
            return Parameter.makeBody(from: [.message: message])
        case let .markAsRead(userID):
            return Parameter.makeBody(from: [.fromUserID: userID.description])
        case let .createJournal(_, title):
            return Parameter.makeBody(from: [.title: title])
        case let .saveJournalEntry(_, _, message),
             let .editEntry(_, _, _, message):
            return Parameter.makeBody(from: [.message: message])
        case let .editJournalSettings(_, _, title, viewAccess, commentAccess):
            return Parameter.makeBody(
                from: [
                    .title: title,
                    .viewAccess: viewAccess.description,
                    .commentAccess: commentAccess.description
                ]
            )
        case let .createEvent(form), let .editEvent(_, form):
            let params = Parameter.makeBodyWithMultipartForm(
                from: [
                    .title: form.title,
                    .description: form.description,
                    .date: form.dateIsoString,
                    .areaID: form.sportsGround.id.description
                ],
                with: form.newMediaFiles
            )
            return params
        case let .createSportsGround(form), let .editSportsGround(_, form):
            return Parameter.makeBodyWithMultipartForm(
                from: [
                    .address: form.address,
                    .latitude: form.latitude,
                    .longitude: form.longitude,
                    .cityID: form.cityID.description,
                    .typeID: form.typeID.description,
                    .classID: form.sizeID.description
                ],
                with: form.newMediaFiles
            )
        }
    }
}

// MARK: - APIError
private extension APIService {
    enum APIError: Error, LocalizedError {
        case noData
        case noResponse
        case badRequest
        case invalidCredentials
        case notFound
        case payloadTooLarge
        case serverError
        case invalidUserID
        case customError(String)

        init(_ error: ErrorResponse) {
            if let message = error.message, error.realCode != 401 {
                self = .customError(message)
            } else if let array = error.errors {
                let message = array.joined(separator: ",\n")
                self = .customError(message)
            } else {
                self.init(with: error.realCode)
            }
        }

        init(with code: Int?) {
            switch code {
            case 400: self = .badRequest
            case 401: self = .invalidCredentials
            case 404: self = .notFound
            case 413: self = .payloadTooLarge
            case 500: self = .serverError
            default: self = .noResponse
            }
        }

        var errorDescription: String? {
            switch self {
            case .noData:
                return "Сервер не прислал данные для обработки ответа"
            case .noResponse:
                return "Сервер не отвечает"
            case .badRequest:
                return "Запрос содержит ошибку"
            case .invalidCredentials:
                return "Некорректное имя пользователя или пароль"
            case .notFound:
                return "Запрашиваемый ресурс не найден"
            case .payloadTooLarge:
                return "Объем данных для загрузки на сервер превышает лимит"
            case .serverError:
                return "Внутренняя ошибка сервера"
            case .invalidUserID:
                return "Некорректный идентификатор пользователя"
            case let .customError(error):
                return error
            }
        }
    }
}

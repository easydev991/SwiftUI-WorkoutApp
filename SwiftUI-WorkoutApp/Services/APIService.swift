import Foundation

struct APIService {
    private let defaults = DefaultsService()

    /// Выполняет регистрацию пользователя
    /// - Parameter model: необходимые для регистрации данные
    /// - Returns: Вся информация о пользователе
    func registration(with model: MainUserForm) async throws {
        let endpoint = Endpoint.registration(form: model)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest)
        await defaults.saveAuthData(.init(login: model.userName, password: model.password))
        await defaults.saveUserInfo(result)
    }

    /// Запрашивает `id` пользователя для входа в учетную запись
    /// - Parameters:
    ///   - login: логин или email для входа
    ///   - password: пароль от учетной записи
    func logInWith(_ login: String, _ password: String) async throws {
        let authData = AuthData(login: login, password: password)
        let endpoint = Endpoint.login(auth: authData)
        let result = try await makeResult(LoginResponse.self, for: endpoint.urlRequest)
        await defaults.saveAuthData(authData)
        try await getUserByID(result.userID, loginFlow: true)
    }

    /// Запрашивает данные пользователя по `id`, сохраняет данные главного пользователя в `defaults` и авторизует, если еще не авторизован
    /// - Parameter userID: `id` пользователя
    /// - Returns: Вся информация о пользователе
    @discardableResult
    func getUserByID(_ userID: Int, loginFlow: Bool = false) async throws -> UserResponse {
        let endpoint = Endpoint.getUser(id: userID)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest)
        if loginFlow || userID == defaults.mainUserID {
            await defaults.saveUserInfo(result)
        }
        return result
    }

    /// Сбрасывает пароль для неавторизованного пользователя с указанным логином
    /// - Parameter login: `login` пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func resetPassword(for login: String) async throws -> Bool {
        let endpoint = Endpoint.resetPassword(login: login)
        let response = try await makeResult(LoginResponse.self, for: endpoint.urlRequest)
        return response.userID != .zero
    }

    /// Изменяет данные пользователя
    /// - Parameters:
    ///   - id: `id` пользователя
    ///   - model: данные для изменения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editUser(_ id: Int, model: MainUserForm) async throws -> Bool {
        let authData = defaults.basicAuthInfo
        let endpoint = Endpoint.editUser(id: id, form: model)
        let result = try await makeResult(UserResponse.self, for: endpoint.urlRequest)
        await defaults.saveAuthData(.init(login: model.userName, password: authData.password))
        await defaults.saveUserInfo(result)
        return result.userName == model.userName
    }

    /// Меняет текущий пароль на новый
    /// - Parameters:
    ///   - current: текущий пароль
    ///   - new: новый пароль
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func changePassword(current: String, new: String) async throws -> Bool {
        let endpoint = Endpoint.changePassword(currentPass: current, newPass: new)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Запрашивает удаление профиля текущего пользователя приложения
    func deleteUser() async throws {
        let endpoint = Endpoint.deleteUser(auth: defaults.basicAuthInfo)
        if try await makeStatus(for: endpoint.urlRequest) {
            await defaults.triggerLogout()
        }
    }

    /// Загружает список друзей для выбранного пользователя; для главного пользователя в случае успеха сохраняет идентификаторы друзей в `defaults`
    /// - Parameter id: `id` пользователя
    /// - Returns: Список друзей выбранного пользователя
    @discardableResult
    func getFriendsForUser(id: Int) async throws -> [UserResponse] {
        let endpoint = Endpoint.getFriendsForUser(id: id)
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest)
        if id == defaults.mainUserID {
            await defaults.saveFriendsIds(result.compactMap(\.userID))
        }
        return result
    }

    /// Загружает список заявок на добавление в друзья, в случае успеха - сохраняет в `defaults`
    func getFriendRequests() async throws {
        let endpoint = Endpoint.getFriendRequests(auth: defaults.basicAuthInfo)
        let result = try await makeResult([UserResponse].self, for: endpoint.urlRequest)
        await defaults.saveFriendRequests(result)
    }

    /// Отвечает на заявку для добавления в друзья, и в случае успеха запрашивает список заявок повторно, а если запрос одобрен - дополнительно запрашивает список друзей
    /// - Parameters:
    ///   - userID: `id` инициатора заявки
    ///   - accept: `true` - одобрить заявку, `false` - отклонить
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func respondToFriendRequest(from userID: Int, accept: Bool) async throws -> Bool {
        let endpoint: Endpoint = accept
        ? .acceptFriendRequest(from: userID)
        : .declineFriendRequest(from: userID)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest)
        if isSuccess {
            if accept {
                try await getFriendsForUser(id: defaults.mainUserID)
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
    func friendAction(userID: Int, option: Constants.FriendAction) async throws -> Bool {
        let endpoint: Endpoint = option == .sendFriendRequest
        ? .sendFriendRequest(to: userID)
        : .deleteFriend(userID)
        let isSuccess = try await makeStatus(for: endpoint.urlRequest)
        if isSuccess && option == .removeFriend {
            try await getFriendsForUser(id: defaults.mainUserID)
        }
        return isSuccess
    }

    /// Ищет пользователей, чей логин содержит указанный текст
    /// - Parameter name: текст для поиска
    /// - Returns: Список пользователей, чей логин содержит указанный текст
    func findUsers(with name: String) async throws -> [UserResponse] {
        let endpoint = Endpoint.findUsers(with: name)
        return try await makeResult([UserResponse].self, for: endpoint.urlRequest)
    }

    /// Загружает список всех площадок
    /// - Returns: Список всех площадок
    func getAllSportsGrounds() async throws -> [SportsGround] {
        try await makeResult([SportsGround].self, for: Endpoint.getAllSportsGrounds.urlRequest)
    }

    /// Загружает список всех площадок, обновленных после указанной даты
    /// - Parameter stringDate: дата отсечки для поиска обновленных площадок
    /// - Returns: Список обновленных площадок
    func getUpdatedSportsGrounds(from stringDate: String) async throws -> [SportsGround] {
        let endpoint = Endpoint.getUpdatedSportsGrounds(from: stringDate)
        return try await makeResult([SportsGround].self, for: endpoint.urlRequest)
    }

    /// Загружает данные по отдельной площадке
    /// - Parameter id: `id` площадки
    /// - Returns: Вся информация о площадке
    func getSportsGround(id: Int) async throws -> SportsGround {
        let endpoint = Endpoint.getSportsGround(id: id)
        return try await makeResult(SportsGround.self, for: endpoint.urlRequest)
    }

    /// Изменяет данные выбранной площадки
    /// - Parameters:
    ///   - id: `id` площадки
    ///   - form: форма с данными о площадке
    /// - Returns: Обновленная информация о площадке
    func saveSportsGround(id: Int?, form: SportsGroundForm) async throws -> SportsGroundResult {
#warning("TODO: когда на бэке поправят формат данных в ответе по полям city_id, type_id, class_id, заменить эту модель на SportsGround")
        let endpoint: Endpoint
        if let id = id {
            endpoint = Endpoint.editSportsGround(id: id, form: form)
        } else {
            endpoint = Endpoint.createSportsGround(form: form)
        }
        return try await makeResult(SportsGroundResult.self, for: endpoint.urlRequest)
    }

    /// Добавить комментарий для площадки
    /// - Parameters:
    ///   - model: тип комментария (к площадке или мероприятию)
    ///   - comment: текст комментария
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func addNewEntry(to model: Constants.TextEntryType, entryText: String) async throws -> Bool {
        let endpoint: Endpoint
        switch model {
        case let .ground(id):
            endpoint = Endpoint.addCommentToSportsGround(groundID: id, comment: entryText)
        case let .event(id):
            endpoint = Endpoint.addCommentToEvent(eventID: id, comment: entryText)
        case let .journal(id):
            endpoint = Endpoint.saveJournalEntry(
                userID: defaults.mainUserID,
                journalID: id,
                message: entryText
            )
        }
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Изменить свой комментарий для площадки
    /// - Parameters:
    ///   - type: тип записи
    ///   - entryID: `id` записи
    ///   - newEntryText: текст измененной записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editEntry(for type: Constants.TextEntryType, entryID: Int, newEntryText: String) async throws -> Bool {
        let endpoint: Endpoint
        switch type {
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
            endpoint = .editEntry(
                userID: defaults.mainUserID,
                journalID: id,
                entryID: entryID,
                newEntryText: newEntryText
            )
        }
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Удалить запись
    /// - Parameters:
    ///   - type: тип записи
    ///   - entryID: `id` записи
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func deleteEntry(from type: Constants.TextEntryType, entryID: Int) async throws -> Bool {
        let endpoint: Endpoint
        switch type {
        case let .ground(id):
            endpoint = .deleteGroundComment(id, commentID: entryID)
        case let .event(id):
            endpoint = .deleteEventComment(id, commentID: entryID)
        case let .journal(id):
            endpoint = .deleteEntry(
                userID: defaults.mainUserID,
                journalID: id,
                entryID: entryID
            )
        }
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Получить список площадок, где тренируется пользователь
    /// - Parameter userID: `id` пользователя
    /// - Returns: Список площадок, где тренируется пользователь
    func getSportsGroundsForUser(_ userID: Int) async throws -> [SportsGround] {
        let endpoint = Endpoint.getSportsGroundsForUser(userID)
        return try await makeResult([SportsGround].self, for: endpoint.urlRequest)
    }

    /// Изменить статус "тренируюсь здесь" для площадки
    /// - Parameters:
    ///   - groundID: `id` площадки
    ///   - trainHere: `true` - тренируюсь здесь, `false` - не тренируюсь здесь
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func changeTrainHereStatus(for groundID: Int, trainHere: Bool) async throws -> Bool {
        let endpoint: Endpoint = trainHere
        ? .postTrainHere(groundID)
        : .deleteTrainHere(groundID)
        let isOk = try await makeStatus(for: endpoint.urlRequest)
        await defaults.setHasSportsGrounds(trainHere)
        return isOk
    }

    /// Запрашивает список мероприятий
    /// - Parameter type: тип мероприятия (предстоящее или прошедшее)
    /// - Returns: Список мероприятий
    func getEvents(of type: EventType) async throws -> [EventResponse] {
        let endpoint: Endpoint = type == .future ? .getFutureEvents : .getPastEvents
        return try await makeResult([EventResponse].self, for: endpoint.urlRequest)
    }

    /// Запрашивает конкретное мероприятие
    /// - Parameter id: `id` мероприятия
    /// - Returns: Вся информация по мероприятию
    func getEvent(by id: Int) async throws -> EventResponse {
        try await makeResult(EventResponse.self, for: Endpoint.getEvent(id: id).urlRequest)
    }

    /// Отправляет новое мероприятие на сервер
    /// - Parameter form: форма с данными по мероприятию
    /// - Returns: Сервер возвращает `EventResponse`, но с неправильным форматом `area_id` (строка), поэтому временно обрабатываем `EventResult`
    func saveEvent(_ form: EventForm, eventID: Int?) async throws -> EventResult {
#warning("TODO: Поменять формат ответа, когда на бэке починят, чтобы сохранять мероприятие в список futureEvents внутри EventsListViewModel")
        let endpoint: Endpoint
        if let eventID = eventID {
            endpoint = .editEvent(id: eventID, form: form)
        } else {
            endpoint = .createEvent(form: form)
        }
        return try await makeResult(EventResult.self, for: endpoint.urlRequest)
    }

    /// Изменить статус "пойду на мероприятие" для мероприятия
    /// - Parameters:
    ///   - groundID: `id` мероприятия
    ///   - trainHere: `true` - иду на мероприятие, `false` - не иду
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func changeIsGoingToEvent(for eventID: Int, isGoing: Bool) async throws -> Bool {
        let endpoint: Endpoint = isGoing
        ? .postIsGoingToEvent(id: eventID)
        : .deleteIsGoingToEvent(id: eventID)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Удалить мероприятие
    /// - Parameter eventID: `id` мероприятия
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func delete(eventID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteEvent(id: eventID)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Удалить площадку
    /// - Parameter groundID: `id` площадки
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func delete(groundID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteSportsGround(id: groundID)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Запрашивает список диалогов для текущего пользователя
    /// - Returns: Список диалогов
    func getDialogs() async throws -> [DialogResponse] {
        let endpoint = Endpoint.getDialogs(auth: defaults.basicAuthInfo)
        return try await makeResult([DialogResponse].self, for: endpoint.urlRequest)
    }

    /// Запрашивает сообщения для выбранного диалога, по умолчанию лимит 30 сообщений
    /// - Parameter dialog: `id` диалога
    /// - Returns: Сообщения в диалоге
    func getMessages(for dialog: Int) async throws -> [MessageResponse] {
        let endpoint = Endpoint.getMessages(dialogID: dialog)
        return try await makeResult([MessageResponse].self, for: endpoint.urlRequest)
    }

    /// Отправляет сообщение указанному пользователю
    /// - Parameters:
    ///   - message: отправляемое сообщение
    ///   - userID: `id` получателя сообщения
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func sendMessage(_ message: String, to userID: Int) async throws -> Bool {
        let endpoint = Endpoint.sendMessageTo(message, userID)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Отмечает сообщения от выбранного пользователя как прочитанные
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func markAsRead(from userID: Int) async throws -> Bool {
        let endpoint = Endpoint.markAsRead(from: userID)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Удаляет выбранный диалог
    /// - Parameter dialogID: `id` диалога для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func deleteDialog(_ dialogID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteDialog(id: dialogID)
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Запрашивает список дневников для выбранного пользователя
    /// - Parameter userID: `id` выбранного пользователя
    /// - Returns: Список дневников
    func getJournals(for userID: Int) async throws -> [JournalResponse] {
        let endpoint = Endpoint.getJournals(userID: userID)
        let result = try await makeResult([JournalResponse].self, for: endpoint.urlRequest)
        if userID == defaults.mainUserID {
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
        let endpoint = Endpoint.getJournal(
            userID: userID,
            journalID: journalID
        )
        return try await makeResult(JournalResponse.self, for: endpoint.urlRequest)
    }

    /// Меняет настройки дневника
    /// - Parameters:
    ///   - journalID: `id` выбранного дневника
    ///   - title: название дневника
    ///   - viewAccess: доступ на просмотр
    ///   - commentAccess: доступ на комментирование
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func editJournalSettings(for journalID: Int, title: String, viewAccess: Constants.JournalAccess, commentAccess: Constants.JournalAccess) async throws -> Bool {
        let endpoint = Endpoint.editJournalSettings(
            userID: defaults.mainUserID,
            journalID: journalID,
            title: title,
            viewAccess: viewAccess.rawValue,
            commentAccess: commentAccess.rawValue
        )
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Создает новый дневник для пользователя
    /// - Parameter title: название дневника
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func createJournal(with title: String) async throws -> Bool {
        let endpoint = Endpoint.createJournal(
            userID: defaults.mainUserID,
            title: title
        )
        return try await makeStatus(for: endpoint.urlRequest)
    }

    /// Запрашивает записи из дневника пользователя
    /// - Parameters:
    ///   - userID: `id` пользователя
    ///   - journalID: `id` выбранного дневника
    /// - Returns: Все записи из выбранного дневника
    func getJournalEntries(for userID: Int, journalID: Int) async throws -> [JournalEntryResponse] {
        let endpoint = Endpoint.getJournalEntries(
            userID: userID,
            journalID: journalID
        )
        return try await makeResult([JournalEntryResponse].self, for: endpoint.urlRequest)
    }

    /// Удаляет выбранный дневник
    /// - Parameters:
    ///   - userID: `id` владельца дневника
    ///   - journalID: `id` дневника для удаления
    /// - Returns: `true` в случае успеха, `false` при ошибках
    func deleteJournal(journalID: Int) async throws -> Bool {
        let endpoint = Endpoint.deleteJournal(
            userID: defaults.mainUserID,
            journalID: journalID
        )
        return try await makeStatus(for: endpoint.urlRequest)
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
        return try await makeStatus(for: endpoint.urlRequest)
    }
}

private extension APIService {
    var urlSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.timeOut
        config.timeoutIntervalForResource = Constants.API.timeOut
        config.waitsForConnectivity = true
        return .init(configuration: config)
    }

    /// Загружает данные в нужном формате или отдает ошибку
    /// - Parameters:
    ///   - type: тип, который нужно загрузить
    ///   - request: запрос, по которому нужно обратиться
    /// - Returns: Вся информация по запрошенному типу
    func makeResult<T: Codable>(_ type: T.Type, for request: URLRequest?) async throws -> T {
        guard let request = request else { throw APIError.badRequest }
        let (data, response) = try await urlSession.data(for: request)
        let result = try handle(type.self, data, response)
        return result
    }

    /// Выполняет действие, не требующее указания типа
    /// - Parameter request: запрос, по которому нужно обратиться
    /// - Returns: Статус действия
    func makeStatus(for request: URLRequest?) async throws -> Bool {
        guard let request = request else { throw APIError.badRequest }
        let (_, response) = try await urlSession.data(for: request)
        return try handle(response)
    }

    /// Обрабатывает ответ сервера и возвращает данные в нужном формате
    func handle<T: Decodable>(
        _ type: T.Type,
        _ data: Data?,
        _ response: URLResponse?
    ) throws -> T {
        guard let data = data, !data.isEmpty else {
            throw APIError.noData
        }
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != Constants.API.codeOK {
            throw handleError(from: data, with: responseCode)
        }
#if DEBUG
        print("--- Получили ответ:")
        dump(response)
        print("--- Полученный JSON:\n\(data.prettyJson)")
        do {
            _ = try JSONDecoder().decode(type, from: data)
        } catch {
            print("--- error: \(error)")
        }
#endif
        let decodedInfo = try JSONDecoder().decode(type, from: data)
#if DEBUG
        print("--- Преобразованные данные:\n\(decodedInfo)")
#endif
        return decodedInfo
    }

    /// Обрабатывает ответ сервера, в котором важен только статус
    func handle(_ response: URLResponse?) throws -> Bool {
#if DEBUG
        print("--- Получили ответ:")
        dump(response)
#endif
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        if responseCode != Constants.API.codeOK {
            throw APIError(with: responseCode)
        }
        return responseCode == Constants.API.codeOK
    }

    /// Обрабатывает ошибки
    /// - Parameters:
    ///   - data: данные для обработки
    ///   - code: код ответа
    /// - Returns: Готовая к выводу ошибка `APIError`
    func handleError(from data: Data, with code: Int?) -> APIError {
#if DEBUG
        print("--- JSON с ошибкой:")
        print(data.prettyJson)
#endif
        if let errorInfo = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return APIError(errorInfo)
        } else {
            return APIError(with: code)
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
        /// **POST** ${API}/auth/login,
        case login(auth: AuthData)

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
        case getFriendRequests(auth: AuthData)

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

        // MARK: Найти пользователей по логину
        /// **GET** ${API}/users/search?name=<user>
        case findUsers(with: String)

        // MARK: Получить список всех площадок
        /// **GET** ${API}/areas
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
        case deleteSportsGround(id: Int)

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
        case postIsGoingToEvent(id: Int)

        // MARK: Сообщить, что пользователь не пойдет на мероприятие
        /// **DELETE** ${API}/trainings/<event_id>/go
        case deleteIsGoingToEvent(id: Int)

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
        case deleteEvent(id: Int)

        // MARK: Получить список диалогов
        /// **GET** ${API}/dialogs
        case getDialogs(auth: AuthData)

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

        var urlRequest: URLRequest? {
            guard let url = URL(string: urlPath) else { return nil }
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
        let baseUrl = Constants.API.baseURL
        switch self {
        case .registration:
            return "\(baseUrl)/registration"
        case .login:
            return "\(baseUrl)/auth/login"
        case .resetPassword:
            return "\(baseUrl)/auth/reset"
        case let .editUser(userID, _):
            return "\(baseUrl)/users/\(userID)"
        case .changePassword:
            return "\(baseUrl)/auth/changepass"
        case .deleteUser:
            return "\(baseUrl)/users/current"
        case let .getUser(id):
            return "\(baseUrl)/users/\(id)"
        case let .getFriendsForUser(id):
            return "\(baseUrl)/users/\(id)/friends"
        case .getFriendRequests:
            return "\(baseUrl)/friends/requests"
        case let .acceptFriendRequest(userID),
            let .declineFriendRequest(userID):
            return "\(baseUrl)/friends/\(userID)/accept"
        case let .sendFriendRequest(userID),
            let .deleteFriend(userID):
            return "\(baseUrl)/friends/\(userID)"
        case let .findUsers(name):
            return "\(baseUrl)/users/search?name=\(name)"
        case .getAllSportsGrounds:
            return "\(baseUrl)/areas?fields=short"
        case let .getUpdatedSportsGrounds(date):
            return "\(baseUrl)/areas/last/\(date)"
        case .createSportsGround:
            return "\(baseUrl)/areas"
        case let .getSportsGround(id),
            let .editSportsGround(id, _),
            let .deleteSportsGround(id):
            return "\(baseUrl)/areas/\(id)"
        case let .addCommentToSportsGround(groundID, _):
            return "\(baseUrl)/areas/\(groundID)/comments"
        case let .editGroundComment(groundID, commentID, _):
            return "\(baseUrl)/areas/\(groundID)/comments/\(commentID)"
        case let .deleteGroundComment(groundID, commentID):
            return "\(baseUrl)/areas/\(groundID)/comments/\(commentID)"
        case let .getSportsGroundsForUser(userID):
            return "\(baseUrl)/users/\(userID)/areas"
        case let .postTrainHere(groundID), let .deleteTrainHere(groundID):
            return "\(baseUrl)/areas/\(groundID)/train"
        case .getFutureEvents:
            return "\(baseUrl)/trainings/current"
        case .getPastEvents:
            return "\(baseUrl)/trainings/last"
        case let .getEvent(id):
            return "\(baseUrl)/trainings/\(id)"
        case .createEvent:
            return "\(baseUrl)/trainings"
        case let .postIsGoingToEvent(id), let .deleteIsGoingToEvent(id):
            return "\(baseUrl)/trainings/\(id)/go"
        case let .addCommentToEvent(id, _):
            return "\(baseUrl)/trainings/\(id)/comments"
        case let .deleteEventComment(eventID, commentID):
            return "\(baseUrl)/trainings/\(eventID)/comments/\(commentID)"
        case let .editEventComment(eventID, commentID, _):
            return "\(baseUrl)/trainings/\(eventID)/comments/\(commentID)"
        case let .deleteEvent(id), let .editEvent(id, _):
            return "\(baseUrl)/trainings/\(id)"
        case .getDialogs:
            return "\(baseUrl)/dialogs"
        case let .getMessages(dialogID):
            return "\(baseUrl)/dialogs/\(dialogID)/messages"
        case let .sendMessageTo(_, userID):
            return "\(baseUrl)/messages/\(userID)"
        case .markAsRead:
            return "\(baseUrl)/messages/mark_as_read"
        case let .deleteDialog(dialogID):
            return "\(baseUrl)/dialogs/\(dialogID)"
        case let .getJournals(userID),
            let .createJournal(userID, _):
            return "\(baseUrl)/users/\(userID)/journals"
        case let .getJournal(userID, journalID),
            let .deleteJournal(userID, journalID),
            let .editJournalSettings(userID, journalID, _, _, _):
            return "\(baseUrl)/users/\(userID)/journals/\(journalID)"
        case let .getJournalEntries(userID, journalID),
            let .saveJournalEntry(userID, journalID, _):
            return "\(baseUrl)/users/\(userID)/journals/\(journalID)/messages"
        case let .editEntry(userID, journalID, entryID, _),
            let .deleteEntry(userID, journalID, entryID):
            return "\(baseUrl)/users/\(userID)/journals/\(journalID)/messages/\(entryID)"
        case let .deleteEventPhoto(eventID, photoID):
            return "\(baseUrl)/trainings/\(eventID)/photos/\(photoID)"
        case let .deleteGroundPhoto(groundID, photoID):
            return "\(baseUrl)/areas/\(groundID)/photos/\(photoID)"
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
                .createEvent, .editEvent, .postIsGoingToEvent,
                .addCommentToEvent, .editEventComment, .sendMessageTo,
                .createJournal, .markAsRead, .saveJournalEntry,
                .createSportsGround, .editSportsGround:
            return .post
        case .getUser, .getFriendsForUser, .getFriendRequests,
                .getAllSportsGrounds, .getSportsGround,
                .findUsers, .getSportsGroundsForUser,
                .getFutureEvents, .getPastEvents, .getEvent,
                .getDialogs, .getMessages, .getJournals,
                .getJournal, .getJournalEntries,
                .getUpdatedSportsGrounds:
            return .get
        case .declineFriendRequest, .deleteFriend,
                .deleteGroundComment, .deleteTrainHere,
                .deleteUser, .deleteIsGoingToEvent,
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

        enum Key: String {
            case authorization = "Authorization"
            case contentType = "Content-Type"
        }

        static func basicAuth(
            with input: AuthData = DefaultsService().basicAuthInfo,
            withMultipart: Bool = false
        ) -> [String: String] {
            var headers = [String: String]()
            if let encodedString = input.base64Encoded {
                headers[Key.authorization.rawValue] = "Basic \(encodedString)"
            }
            if withMultipart {
                headers[Key.contentType.rawValue] = "multipart/form-data; boundary=\(boundary)"
            }
            return headers
        }
    }

    var headers: [String: String] {
        switch self {
        case let .login(auth):
            return HTTPHeader.basicAuth(with: auth)
        case .getUser, .editUser,
                .changePassword, .getFriendsForUser,
                .getFriendRequests, .acceptFriendRequest,
                .declineFriendRequest, .sendFriendRequest,
                .deleteFriend, .findUsers,
                .deleteUser, .getDialogs,
                .addCommentToSportsGround, .editGroundComment,
                .deleteGroundComment, .getSportsGroundsForUser,
                .postTrainHere, .deleteTrainHere,
                .postIsGoingToEvent, .deleteIsGoingToEvent,
                .addCommentToEvent, .deleteSportsGround,
                .deleteEventComment, .editEventComment,
                .deleteEvent, .getMessages,
                .sendMessageTo, .markAsRead,
                .deleteDialog, .getJournals,
                .getJournal, .createJournal,
                .getJournalEntries, .saveJournalEntry,
                .editEntry, .deleteEntry,
                .deleteJournal, .editJournalSettings,
                .deleteEventPhoto, .deleteGroundPhoto:
            return HTTPHeader.basicAuth()
        case .registration, .resetPassword,
                .getAllSportsGrounds, .getSportsGround,
                .getUpdatedSportsGrounds, .getFutureEvents,
                .getPastEvents, .getEvent:
            return [:]
        case .createSportsGround, .editSportsGround,
                .createEvent, .editEvent:
            return HTTPHeader.basicAuth(withMultipart: true)
        }
    }

    enum Parameter {
        enum Key: String {
            case name, fullname, email, password,
                 comment, message, title, description, date,
                 address, latitude, longitude
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

        static func makeBody(
            from dict: [Key: String],
            with media: [MediaFile] = []
        ) -> Data? {
            dict
                .map { $0.key.rawValue + "=" + $0.value }
                .joined(separator: "&")
                .data(using: .utf8)
        }

        static func makeBodyWithMultipartForm(
            from dict: [Key: String],
            with media: [MediaFile]?
        ) -> Data {
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
                .sendFriendRequest, .deleteFriend, .getSportsGround,
                .deleteGroundComment, .getSportsGroundsForUser,
                .postTrainHere, .deleteTrainHere, .deleteUser,
                .getFutureEvents, .getPastEvents, .getEvent,
                .postIsGoingToEvent, .deleteIsGoingToEvent,
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
            let .editEntry(_,_,_, message):
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
                with: form.newImagesData
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
                with: form.newImagesData
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
        case serverError
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
            case .serverError:
                return "Внутренняя ошибка сервера"
            case let .customError(error):
                return error
            }
        }
    }
}

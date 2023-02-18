import Foundation

enum Constants {
    static let minPasswordSize = 6
    static let photosLimit = 15
    static let minUserAge = Calendar.current.date(byAdding: .year, value: -13, to: .now) ?? .now
    static let maxEventFutureDate = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    static let authInvitationText = "Авторизуйтесь, чтобы иметь доступ ко всем возможностям"
    static let registrationInfoText = "Регистрация доступна на сайте workout.su"
    static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String).valueOrEmpty
    static let appReviewURL = URL(string: "https://apps.apple.com/app/id1035159361?action=write-review")!
    static let workoutShopURL = URL(string: "https://workoutshop.ru")!
    static let developerProfileButton = URL(string: "https://boosty.to/oleg991")!
    static let officialSiteURL = URL(string: "https://workout.su")!
    static let accountCreationURL = URL(string: "https://m.workout.su/users/register")!
    static let feedbackRecipient = ["info@workout.su"]

    enum RulesOfService {
        static let registrationForm = "Принимаю условия **[пользовательского соглашения](https://workout.su/pravila)**"
        static let aboutApp = URL(string: "https://workout.su/pravila")!
    }

    enum Alert {
        static let forgotPassword = "Для восстановления пароля введите логин или email"
        static let friendRequestSent = "Запрос отправлен!"
        static let deleteEvent = "Удалить мероприятие?"
        static let deleteGround = "Удалить площадку?"
        static let deleteJournal = "Удалить дневник?"
        static let deleteJournalEntry = "Удалить запись из дневника?"
        static let deleteDialog = "Удалить диалог?"
        static let logout = "Выйти из учетной записи?"
        static let deleteProfile = "Удалить учетную запись без возможности восстановления?"
        static let resetSuccessful = "Инструкция для восстановления пароля выслана на email, указанный при регистрации"
        static let locationPermissionDenied = "Запрещен доступ к геолокации"
        static let needLocationPermission = "Для отображения твоего местоположения необходимо разрешить доступ к геолокации в настройках"
        static let eventCreationRule = "Чтобы создать мероприятие, нужно указать хотя бы одну площадку, где ты тренируешься"
    }
}

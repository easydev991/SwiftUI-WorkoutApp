import Foundation

public enum Constants {
    public static let minPasswordSize = 6
    public static let photosLimit = 15
    public static let minUserAge = Calendar.current.date(byAdding: .year, value: -13, to: .now) ?? .now
    public static let maxEventFutureDate = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    public static let authInvitationText = "Авторизуйтесь, чтобы иметь доступ ко всем возможностям"
    public static let registrationInfoText = "Регистрация доступна на сайте workout.su"
    public static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String).valueOrEmpty
    public static let appReviewURL = URL(string: "https://apps.apple.com/app/id1035159361?action=write-review")!
    public static let workoutShopURL = URL(string: "https://workoutshop.ru")!
    public static let developerProfileButton = URL(string: "https://boosty.to/oleg991")!
    public static let officialSiteURL = URL(string: "https://workout.su")!
    public static let accountCreationURL = URL(string: "https://m.workout.su/users/register")!
    public static let feedbackRecipient = ["info@workout.su"]

    public enum RulesOfService {
        public static let registrationForm = "Принимаю условия **[пользовательского соглашения](https://workout.su/pravila)**"
        public static let aboutApp = URL(string: "https://workout.su/pravila")!
    }

    public enum Alert {
        public static let forgotPassword = "Для восстановления пароля введите логин или email"
        public static let friendRequestSent = "Запрос отправлен!"
        public static let deleteEvent = "Удалить мероприятие?"
        public static let deleteGround = "Удалить площадку?"
        public static let deleteJournal = "Удалить дневник?"
        public static let deleteJournalEntry = "Удалить запись из дневника?"
        public static let deleteDialog = "Удалить диалог?"
        public static let logout = "Выйти из учетной записи?"
        public static let deleteProfile = "Удалить учетную запись без возможности восстановления?"
        public static let resetSuccessful = "Инструкция для восстановления пароля выслана на email, указанный при регистрации"
        public static let locationPermissionDenied = "Запрещен доступ к геолокации"
        public static let needLocationPermission =
            "Для отображения твоего местоположения необходимо разрешить доступ к геолокации в настройках"
        public static let eventCreationRule = "Чтобы создать мероприятие, нужно указать хотя бы одну площадку, где ты тренируешься"
    }
}

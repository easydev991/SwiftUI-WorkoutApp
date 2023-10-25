import Foundation

public enum Constants {
    public static let minPasswordSize = 6
    public static let photosLimit = 15
    public static let minUserAge = Calendar.current.date(byAdding: .year, value: -13, to: .now) ?? .now
    public static let authInvitationText = "Авторизуйтесь, чтобы иметь доступ ко всем возможностям"
    public static let registrationInfoText = "Регистрация доступна на сайте workout.su"
    public static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    public static let feedbackRecipient = ["info@workout.su"]

    public enum Alert {
        public static let forgotPassword = "Для восстановления пароля введите логин или email"
        public static let friendRequestSent = "Запрос отправлен!"
        public static let deleteEvent = "Удалить мероприятие?"
        public static let deleteGround = "Удалить площадку?"
        public static let deleteJournal = "Удалить дневник?"
        public static let deleteJournalEntry = "Удалить запись из дневника?"
        public static let deleteDialog = "Удалить диалог?"
        public static let logout = "Выйти из учетной записи?"
        public static let groundFeedback = "Нужно обновить данные о площадке?"
        public static let resetSuccessful = "Инструкция для восстановления пароля выслана на email, указанный при регистрации"
        public static let locationPermissionDenied = "Запрещен доступ к геолокации"
        public static let needLocationPermission =
            "Для отображения твоего местоположения необходимо разрешить доступ к геолокации в настройках"
        public static let eventCreationRule = "Чтобы создать мероприятие, нужно указать хотя бы одну площадку, где ты тренируешься"
    }
}
